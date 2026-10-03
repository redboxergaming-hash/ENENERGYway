"""Generate original short synthesized UI/machine cues. No downloaded samples."""
from pathlib import Path
import math, struct, wave
OUT=Path(__file__).resolve().parents[1]/'audio'
rate=22050
def save(name, seconds, sample):
    with wave.open(str(OUT/(name+'.wav')),'wb') as w:
        w.setnchannels(1);w.setsampwidth(2);w.setframerate(rate)
        w.writeframes(b''.join(struct.pack('<h',int(max(-1,min(1,sample(i/rate)))*15000)) for i in range(int(seconds*rate))))
save('pickup',.13,lambda t: math.sin(2*math.pi*(580*t+1700*t*t))*math.sin(math.pi*t/.13)*.35)
save('can_ready',.24,lambda t: (math.sin(2*math.pi*880*t)+.3*math.sin(2*math.pi*1760*t))*math.exp(-t*18)*.3)
save('delivery',.22,lambda t: math.sin(2*math.pi*(700*t+650*t*t))*math.sin(math.pi*t/.22)*.4)
notes=[523.25,659.25,783.99,1046.5]
save('order_complete',.8,lambda t: math.sin(2*math.pi*notes[min(3,int(t/.2))]*t)*math.sin(math.pi*(t%.2)/.2)*.4)
save('machine_loop',1,lambda t: .09*math.sin(2*math.pi*60*t)+.05*math.sin(2*math.pi*120*t)+.02*math.sin(2*math.pi*240*t))
