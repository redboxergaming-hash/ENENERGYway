"""Validate ZIP, universal Mach-O code-page signatures and signed resource hashes.
This is structural verification, not a macOS runtime / Gatekeeper test.
"""
from pathlib import Path
import hashlib, json, plistlib, struct, sys, zipfile
path=Path(sys.argv[1] if len(sys.argv)>1 else 'downloads/ENERGY-INC-macOS.zip')
with zipfile.ZipFile(path) as z:
    assert z.testzip() is None, 'ZIP CRC failure'
    plist_name=next(n for n in z.namelist() if n.endswith('/Info.plist'))
    prefix=plist_name.removesuffix('Info.plist')
    info=plistlib.loads(z.read(plist_name))
    executable=prefix+'MacOS/'+info['CFBundleExecutable']
    entry=z.getinfo(executable)
    assert (entry.external_attr >> 16)&0o111, 'Executable bit missing'
    binary=z.read(executable)
    magic,count=struct.unpack_from('>II',binary)
    assert magic==0xcafebabe and count==2, 'Not a two-architecture universal binary'
    architectures=[]
    for i in range(count):
        cpu,subtype,offset,size,alignment=struct.unpack_from('>IIIII',binary,8+i*20)
        name={0x1000007:'x86_64',0x100000c:'arm64'}[cpu]
        architectures.append(name)
        header=struct.unpack_from('<IIIIIIII',binary,offset)
        assert header[0]==0xfeedfacf
        cursor=offset+32
        signature=None
        for _ in range(header[4]):
            command,length=struct.unpack_from('<II',binary,cursor)
            if command==0x1d:
                start,nbytes=struct.unpack_from('<II',binary,cursor+8)
                signature=binary[offset+start:offset+start+nbytes]
            cursor+=length
        assert signature is not None,f'{name}: missing code signature'
        smagic,slength,scount=struct.unpack_from('>III',signature)
        assert smagic==0xfade0cc0
        directories=[]
        for j in range(scount):
            slot,where=struct.unpack_from('>II',signature,12+j*8)
            if slot==0 or 0x1000<=slot<0x1005:
                cd=signature[where:]
                cmagic,length,version,flags,hash_offset,ident_offset,special_slots,code_slots,limit=struct.unpack_from('>9I',cd)
                assert cmagic==0xfade0c02 and flags&2, f'{name}: expected ad-hoc signature'
                hash_size,hash_type,platform,page=struct.unpack_from('>4B',cd,36)
                digest={1:hashlib.sha1,2:hashlib.sha256,3:hashlib.sha256,4:hashlib.sha384}[hash_type]
                for page_index in range(code_slots):
                    start=page_index*(1<<page)
                    content=binary[offset+start:offset+min(limit,start+(1<<page))]
                    expected=cd[hash_offset+page_index*hash_size:hash_offset+(page_index+1)*hash_size]
                    assert digest(content).digest()[:hash_size]==expected, f'{name}: invalid signed page {page_index}'
                directories.append(code_slots)
        assert directories
        print(f'{name}: validated {sum(directories)} signed code pages')
    assert set(architectures)=={'arm64','x86_64'}
    resources=plistlib.loads(z.read(prefix+'_CodeSignature/CodeResources'))
    checked=0
    for resource,record in resources.get('files2',{}).items():
        if isinstance(record,dict) and 'hash2' in record:
            assert hashlib.sha256(z.read(prefix+resource)).digest()==record['hash2'],f'Invalid resource hash: {resource}'
            checked+=1
    assert checked>0
    pack=next(n for n in z.namelist() if n.endswith('.pck'))
    Path('/tmp/energy-macos.pck').write_bytes(z.read(pack))
    print(json.dumps({'version':info['CFBundleShortVersionString'],'architectures':architectures,'verified_resources':checked,'zip_bytes':path.stat().st_size,'sha256':hashlib.sha256(path.read_bytes()).hexdigest(),'native_macos_execution':'not tested'}))
