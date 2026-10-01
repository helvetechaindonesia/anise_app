import wave
import struct
import math
import random
import os

# Create directory if it doesn't exist
os.makedirs('f:/projek/anise_app/frontend/assets/sounds', exist_ok=True)

def generate_swoosh():
    file = wave.open('f:/projek/anise_app/frontend/assets/sounds/swoosh.wav', 'w')
    file.setnchannels(1)
    file.setsampwidth(2)
    sample_rate = 44100
    file.setframerate(sample_rate)
    
    duration = 0.8
    num_samples = int(duration * sample_rate)
    
    for i in range(num_samples):
        t = i / sample_rate
        # Envelope: attacks and decays
        envelope = math.sin(math.pi * (i / num_samples)) ** 2
        # Frequency sweep: low to high
        freq = 100 + (800 * (i / num_samples))
        # Mix white noise and sine wave
        noise = random.uniform(-1.0, 1.0) * 0.5
        sine = math.sin(2 * math.pi * freq * t) * 0.5
        
        value = int((noise + sine) * envelope * 32767 * 0.5)
        # Ensure it fits in 16-bit
        value = max(-32768, min(32767, value))
        
        data = struct.pack('<h', value)
        file.writeframesraw(data)
    
    file.close()

def generate_cring():
    file = wave.open('f:/projek/anise_app/frontend/assets/sounds/cring.wav', 'w')
    file.setnchannels(1)
    file.setsampwidth(2)
    sample_rate = 44100
    file.setframerate(sample_rate)
    
    duration = 1.5
    num_samples = int(duration * sample_rate)
    
    for i in range(num_samples):
        t = i / sample_rate
        # Exponential decay envelope
        envelope = math.exp(-3.0 * t)
        
        # Mix of frequencies for a bell/chime sound
        f1 = 1200.0
        f2 = 2400.0
        f3 = 3600.0
        
        wave1 = math.sin(2 * math.pi * f1 * t)
        wave2 = math.sin(2 * math.pi * f2 * t) * 0.5
        wave3 = math.sin(2 * math.pi * f3 * t) * 0.25
        
        value = int((wave1 + wave2 + wave3) * envelope * 32767 * 0.3)
        value = max(-32768, min(32767, value))
        
        data = struct.pack('<h', value)
        file.writeframesraw(data)
    
    file.close()

if __name__ == "__main__":
    generate_swoosh()
    generate_cring()
    print("Sounds generated successfully!")
