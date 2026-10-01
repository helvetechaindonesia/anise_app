const fs = require('fs');
const path = require('path');

const dir = 'f:/projek/anise_app/frontend/assets/sounds';
if (!fs.existsSync(dir)){
    fs.mkdirSync(dir, { recursive: true });
}

function writeWav(filename, duration, getSample) {
    const sampleRate = 44100;
    const numSamples = Math.floor(duration * sampleRate);
    const dataSize = numSamples * 2;
    const fileSize = 36 + dataSize;
    
    const buffer = Buffer.alloc(44 + dataSize);
    
    // RIFF chunk descriptor
    buffer.write('RIFF', 0);
    buffer.writeUInt32LE(fileSize, 4);
    buffer.write('WAVE', 8);
    
    // fmt sub-chunk
    buffer.write('fmt ', 12);
    buffer.writeUInt32LE(16, 16); // Subchunk1Size
    buffer.writeUInt16LE(1, 20); // AudioFormat (PCM)
    buffer.writeUInt16LE(1, 22); // NumChannels
    buffer.writeUInt32LE(sampleRate, 24); // SampleRate
    buffer.writeUInt32LE(sampleRate * 2, 28); // ByteRate
    buffer.writeUInt16LE(2, 32); // BlockAlign
    buffer.writeUInt16LE(16, 34); // BitsPerSample
    
    // data sub-chunk
    buffer.write('data', 36);
    buffer.writeUInt32LE(dataSize, 40);
    
    // Write samples
    let offset = 44;
    for (let i = 0; i < numSamples; i++) {
        let t = i / sampleRate;
        let sample = getSample(t, i, numSamples);
        // Clamp
        sample = Math.max(-32768, Math.min(32767, sample));
        buffer.writeInt16LE(sample, offset);
        offset += 2;
    }
    
    fs.writeFileSync(path.join(dir, filename), buffer);
}

// Generate swoosh
writeWav('swoosh.wav', 0.8, (t, i, numSamples) => {
    // Envelope
    let envelope = Math.pow(Math.sin(Math.PI * (i / numSamples)), 2);
    // Frequency sweep
    let freq = 100 + (800 * (i / numSamples));
    // Mix noise and sine
    let noise = (Math.random() * 2 - 1) * 0.5;
    let sine = Math.sin(2 * Math.PI * freq * t) * 0.5;
    return (noise + sine) * envelope * 32767 * 0.5;
});

// Generate cring
writeWav('cring.wav', 1.5, (t, i, numSamples) => {
    // Exponential decay
    let envelope = Math.exp(-3.0 * t);
    
    let wave1 = Math.sin(2 * Math.PI * 1200 * t);
    let wave2 = Math.sin(2 * Math.PI * 2400 * t) * 0.5;
    let wave3 = Math.sin(2 * Math.PI * 3600 * t) * 0.25;
    
    return (wave1 + wave2 + wave3) * envelope * 32767 * 0.3;
});

console.log("Sounds generated successfully!");
