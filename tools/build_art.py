"""Original ENERGY INC. mesh kit. Run with Blender --background --python tools/build_art.py.
Uses only generated meshes and Blender's bundled font. Coordinates below are Godot XYZ.
"""
import bpy, math
from pathlib import Path
from mathutils import Vector
OUT=Path(__file__).resolve().parents[1]/'art/models'
OUT.mkdir(parents=True,exist_ok=True)
C={'ink':'253744','teal':'208F89','mint':'67CBC0','cream':'F5E5BD','orange':'EE8847','yellow':'F5C452','red':'DB5B64','metal':'ABC2C9','blue':'64B9D8','skin':'EBC39C','white':'FBF4DD','rubber':'172C38','lime':'BFE264','purple':'A5A0D9'}
M={}
def xyz(v): return (v[0],-v[2],v[1])
def mat(name):
    if name not in M:
        h=C.get(name,name); rgb=tuple(int(h[i:i+2],16)/255 for i in (0,2,4))
        linear=tuple(v/12.92 if v<=.04045 else ((v+.055)/1.055)**2.4 for v in rgb)
        m=bpy.data.materials.new(name); m.diffuse_color=(*linear,1); m.use_nodes=True
        bs=m.node_tree.nodes.get('Principled BSDF')
        bs.inputs['Base Color'].default_value=(*linear,1)
        bs.inputs['Roughness'].default_value=.62
        bs.inputs['Metallic'].default_value=.25 if name=='metal' else 0
        M[name]=m
    return M[name]
def finish(o,name,color):
    o.name=name; o.data.materials.append(mat(color)); return o
def box(name,p,s,c,bevel=.06):
    bpy.ops.mesh.primitive_cube_add(size=1,location=xyz(p)); o=bpy.context.object
    o.scale=(s[0],s[2],s[1]); bpy.ops.object.transform_apply(location=False,rotation=False,scale=True)
    if bevel:
        b=o.modifiers.new('Soft manufactured edges','BEVEL'); b.width=min(bevel,min(s)*.43); b.segments=3
        o.modifiers.new('Weighted normals','WEIGHTED_NORMAL')
    return finish(o,name,c)
def sphere(name,p,s,c):
    bpy.ops.mesh.primitive_uv_sphere_add(segments=20,ring_count=12,radius=1,location=xyz(p)); o=bpy.context.object
    o.scale=(s[0],s[2],s[1]); bpy.ops.object.transform_apply(location=False,rotation=False,scale=True)
    for f in o.data.polygons:f.use_smooth=True
    return finish(o,name,c)
def cyl(name,p,r,h,c,d=(0,1,0),r2=None):
    bpy.ops.mesh.primitive_cone_add(vertices=24,radius1=r,radius2=r if r2 is None else r2,depth=h,location=xyz(p))
    o=bpy.context.object; o.rotation_mode='QUATERNION'; o.rotation_quaternion=Vector(xyz(d)).to_track_quat('Z','Y')
    b=o.modifiers.new('Rim bevel','BEVEL'); b.width=min(.035,h*.15); b.segments=3
    o.modifiers.new('Weighted normals','WEIGHTED_NORMAL')
    return finish(o,name,c)
def pipe(name,a,b,r,c):
    av=Vector(a); bv=Vector(b); return cyl(name,(av+bv)/2,r,(bv-av).length,c,(bv-av).normalized())
def empty(name,p=(0,0,0)):
    o=bpy.data.objects.new(name,None); bpy.context.collection.objects.link(o); o.location=xyz(p); return o
def parent(o,p):
    bpy.context.view_layer.update(); w=o.matrix_world.copy(); o.parent=p; o.matrix_world=w
    return o
def text(name,value,p,size,c):
    bpy.ops.object.text_add(location=xyz(p),rotation=(math.pi/2,0,0)); o=bpy.context.object
    o.data.body=value; o.data.align_x='CENTER'; o.data.align_y='CENTER'; o.data.size=size; o.data.extrude=.001
    o.data.materials.append(mat(c)); o.name=name
    bpy.ops.object.convert(target='MESH'); return bpy.context.object
def reset():
    bpy.ops.object.select_all(action='SELECT'); bpy.ops.object.delete(use_global=False)
def save(name):
    bpy.ops.export_scene.gltf(filepath=str(OUT/(name+'.glb')),export_format='GLB',export_apply=True,export_cameras=False,export_lights=False)
    print('ART',name,flush=True)
def feet(x,z,w=1.8):
    for dx in [-w/2,w/2]:
        for dz in [-.5,.5]: cyl('Rubber foot',(x+dx,.12,z+dz),.16,.24,'rubber')
def bolts(y,z,w=1.6):
    for x in [-w/2,w/2]: cyl('Bolt',(x,y,z),.055,.04,'metal',(0,0,1))
# Worker: large rounded head, tiny boots, utility vest and expressive goggles.
reset(); rig=empty('WorkerRig')
body=empty('Torso',(0,.95,0))
parent(box('Suit',(0,.94,0),(.66,.69,.39),'orange',.16),body)
parent(box('Vest',(0,1.02,-.2),(.47,.44,.07),'teal',.06),body)
for x in [-.19,.19]: parent(box('Reflector',(x,1.06,-.25),(.055,.46,.02),'cream',.01),body)
parent(box('Belt',(0,.65,0),(.62,.11,.42),'ink'),body)
parent(box('Buckle',(0,.65,-.24),(.12,.09,.035),'metal'),body)
head=empty('Head',(0,1.47,0))
parent(sphere('Face',(0,1.49,-.015),(.32,.33,.28),'skin'),head)
parent(sphere('Nose',(0,1.45,-.292),(.073,.062,.077),'skin'),head)
for x in [-.145,.145]:
    parent(sphere('Goggle rim',(x,1.55,-.249),(.146,.105,.07),'ink'),head)
    parent(sphere('Lens',(x,1.56,-.292),(.111,.078,.03),'white'),head)
    parent(sphere('Pupil',(x+.02,1.56,-.319),(.033,.049,.014),'rubber'),head)
    parent(sphere('Glint',(x+.008,1.59,-.331),(.012,.015,.006),'white'),head)
parent(sphere('Helmet',(0,1.79,.025),(.36,.21,.31),'yellow'),head)
parent(box('Helmet brim',(0,1.74,-.045),(.79,.09,.72),'yellow',.045),head)
parent(box('Helmet stripe',(0,1.91,0),(.07,.035,.43),'orange'),head)
parent(box('Helmet lamp',(0,1.8,-.319),(.19,.13,.07),'ink'),head)
parent(box('Lamp lens',(0,1.8,-.36),(.12,.07,.01),'cream'),head)
for side,label in [(-1,'Left'),(1,'Right')]:
    arm=empty(label+'Arm',(side*.38,1.2,0))
    parent(sphere('Sleeve',(side*.42,1.04,0),(.15,.25,.16),'orange'),arm)
    parent(sphere('Glove',(side*.43,.77,-.03),(.135,.14,.14),'cream'),arm)
    leg=empty(label+'Leg',(side*.17,.57,0))
    parent(box('Trouser',(side*.17,.35,0),(.255,.45,.28),'teal',.1),leg)
    parent(box('Boot',(side*.17,.13,-.09),(.28,.24,.45),'ink',.09),leg)
    parent(box('Sole',(side*.17,.045,-.09),(.29,.055,.46),'rubber',.024),leg)
save('worker')
# Mixer tank with belly, hazard livery, side pressure plumbing and mechanical lid.
reset(); feet(0,0)
box('Chassis',(0,.36,0),(2.15,.42,1.52),'ink',.15)
cyl('Tank',(0,1.3,0),.87,1.55,'teal')
cyl('Bottom collar',(0,.62,0),.91,.16,'mint')
cyl('Top collar',(0,2.03,0),.94,.17,'cream')
sphere('Lid',(0,2.13,0),(.89,.25,.89),'cream')
cyl('Motor',(0,2.43,0),.31,.42,'orange')
cyl('Motor cap',(0,2.65,0),.34,.07,'ink')
rotor=empty('Rotor',(0,2.68,0))
parent(box('Rotor blade',(0,2.69,0),(1.05,.055,.12),'metal',.025),rotor)
for x in [-.65,.65]: pipe('Tank strap',(x,.7,.61),(x,1.88,.61),.035,'metal')
box('Control housing',(0,1.29,.78),(1.48,.65,.21),'ink',.09)
box('Screen',(0,1.38,.902),(.96,.29,.02),'rubber',.025)
for x,c in [(-.45,'red'),(0,'yellow'),(.45,'mint')]: cyl('Button',(x,1.07,.913),.075,.045,c,(0,0,1))
# Front faces use engine labels so localization does not require rebuilding meshes.
box('Warning badge',(0,.53,.793),(1.6,.13,.04),'yellow',.035)
pipe('Riser',(-.94,.55,-.1),(-.94,1.88,-.1),.09,'metal')
pipe('Steam elbow',(-.94,1.88,-.1),(-.6,1.88,-.1),.09,'metal')
cyl('Pressure gauge',(-.93,1.58,.02),.18,.12,'cream',(0,0,1))
pipe('Needle',(-.93,1.58,.09),(-.85,1.67,.09),.015,'red')
pipe('Outlet',(0,.85,.35),(1.16,.85,.35),.105,'teal')
box('Tray',(1.85,.73,.3),(1.15,.12,1.15),'orange',.05)
box('Tray stand',(1.85,.35,.3),(.22,.7,.7),'ink',.045)
for x in [1.38,2.32]:box('Tray rail',(x,.84,.3),(.06,.1,1.12),'cream',.025)
save('mixer')
# Filler: miniature overhead robot/nozzle over six loading sockets.
reset(); feet(0,0)
box('Base',(0,.36,0),(2.35,.44,1.65),'ink',.13)
box('Orange housing',(0,1.15,-.35),(2.05,1.43,.9),'orange',.18)
box('Cream top',(0,1.88,-.35),(2.16,.22,1.02),'cream',.09)
for x in [-.72,.72]:cyl('Reservoir',(x,2.17,-.35),.24,.4,'mint')
box('Screen backing',(0,1.36,.15),(1.49,.67,.18),'ink',.065)
box('Screen',(0,1.45,.251),(1.13,.26,.02),'rubber',.01)
for x in [-.58,.58]:cyl('Button',(x,1.12,.26),.07,.05,'mint' if x<0 else 'red',(0,0,1))
box('Can deck',(0,.65,.52),(2.2,.14,.63),'metal',.04)
for x in [-.8,-.48,-.16,.16,.48,.8]:
    cyl('Socket',(x,.74,.53),.135,.06,'rubber')
    pipe('Filling head',(x,1.11,.53),(x,1.5,.53),.048,'metal')
pipe('Feed pipe',(0,1.95,-.8),(0,1.95,-1.0),.12,'teal')
box('Output tray',(-1.45,.76,.35),(.62,.12,1.6),'mint',.05)
box('Output foot',(-1.45,.35,.35),(.15,.7,1.1),'ink')
save('filler')
# Ingredient bottles and pressure batch. No external texture dependencies.
for kind,col in [('water','blue'),('caffeine','lime'),('mango','orange')]:
    reset()
    if kind=='water':
        cyl('Bottle',(0,0,0),.24,.55,col); sphere('Shoulder',(0,.22,0),(.24,.16,.24),col)
        cyl('Neck',(0,.36,0),.1,.16,'cream'); cyl('Cap',(0,.46,0),.125,.1,'ink')
    elif kind=='caffeine':
        cyl('Canister',(0,0,0),.25,.66,col)
        cyl('Rim',(0,.31,0),.26,.08,'cream'); cyl('Lid',(0,.39,0),.26,.07,'ink')
    else:
        box('Jerrycan',(0,0,0),(.52,.66,.4),col,.1)
        box('Handle',(0,.42,0),(.34,.16,.14),'cream',.065)
        cyl('Cap',(.15,.37,0),.095,.1,'ink')
    box('Label',(0,0,.22),(.4,.25,.035),'cream',.035)
    box('Stripe',(0,-.12,.241),(.4,.06,.01),'ink',.01)
    save(kind)
reset()
cyl('Keg',(0,0,0),.31,.73,'orange'); cyl('Bottom hoop',(0,-.32,0),.33,.1,'ink'); cyl('Top hoop',(0,.32,0),.33,.1,'cream')
cyl('Spigot',(0,.48,0),.1,.25,'teal'); box('Handle',(0,.47,0),(.42,.06,.1),'teal')
box('Batch label',(0,0,.313),(.45,.33,.04),'cream');save('batch')
for filled in [False,True]:
    reset();cyl('Can body',(0,0,0),.145,.42,'orange' if filled else 'metal')
    for y in [-.21,.21]:cyl('Rim',(0,y,0),.15,.03,'metal')
    cyl('Lid',(0,.225,0),.135,.014,'ink' if not filled else 'metal')
    box('Pull tab',(0,.24,0),(.055,.02,.1),'cream')
    if filled:
        box('Can badge',(0,0,.14),(.19,.28,.023),'cream',.035)
        box('Bolt upper',(.018,.052,.158),(.057,.115,.015),'ink',.01).rotation_euler[1]=-.35
        box('Bolt lower',(-.018,-.046,.158),(.057,.115,.015),'ink',.01).rotation_euler[1]=-.35
    save('filled_can' if filled else 'empty_can')
# Empty can dispenser / shelf.
reset();feet(0,0,1.3)
box('Cabinet',(0,.74,0),(1.75,1.2,1.05),'mint',.1)
box('Top',(0,1.38,0),(1.94,.14,1.22),'cream',.055)
box('Slot',(0,.83,.53),(1.32,.42,.025),'ink')
box('Lip',(0,.63,.64),(1.37,.09,.28),'orange',.035)
for x in [-.52,-.26,0,.26,.52]:cyl('Can stack',(x,1.67,-.2),.11,.45,'metal')
save('can_supply')
# Pallet/carton props.
reset()
for x in [-.4,0,.4]:box('Skid',(x,.07,0),(.15,.13,.95),'ink',.02)
for z in [-.4,-.2,0,.2,.4]:box('Plank',(0,.16,z),(1.12,.09,.17),'cream',.015)
for x,z,h in [(-.27,-.23,.6),(.28,-.23,.8),(0,.25,.55)]:
    box('Carton',(x,.22+h/2,z),(.5,h,.43),'C7A572',.025)
    box('Tape',(x,.225+h,z),(.12,.016,.435),'cream',.004)
    box('Label',(x,.42,z+.224),(.22,.15,.009),'white',.006)
save('pallet')
# Delivery desk with green landing zone and branded hand truck.
reset();feet(0,0,2.0)
box('Delivery counter',(0,.88,0),(2.6,.27,1.5),'teal',.12)
box('Delivery base',(0,.43,0),(2.25,.65,1.17),'cream',.09)
box('Front inset',(0,.49,.6),(1.7,.35,.055),'ink',.035)
box('Landing mat',(0,1.028,0),(2.18,.035,1.17),'mint',.04)
for x in [-.91,.91]:box('Guide',(x,1.07,0),(.06,.08,1.1),'cream',.02)
save('delivery')
# Freestanding orange cone.
reset();box('Foot',(0,.04,0),(.55,.08,.55),'ink',.05)
cyl('Cone',(0,.38,0),.23,.65,'orange',r2=.055)
cyl('Reflective ring',(0,.4,0),.158,.14,'cream',r2=.12);save('cone')
