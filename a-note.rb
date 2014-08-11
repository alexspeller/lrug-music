require 'bundler'
Bundler.require

frequency     = 440.0   # frequency of the note, in hz
sample_rate   = 22050 # frames per second
duration      = 1.0     # seconds

# we want 1 second of the note, so we need 1 second's worth of frames
total_frames = (duration * sample_rate).to_i

# each frame, we want this fraction of a cycle:
cycles_per_frame = frequency / sample_rate

# What is a cycle? A cycle is a full sine wave, which is 2π radians:
increment = 2 * Math::PI * cycles_per_frame

phase = 0

samples = total_frames.times.map do
  sample = Math.sin phase
  phase += increment
  sample
end

filename = 'a.wav'

format = WaveFile::Format.new :mono, :pcm_16, sample_rate
buffer_format = WaveFile::Format.new :mono, :float, sample_rate
WaveFile::Writer.new filename, format do |writer|
  buffer = WaveFile::Buffer.new samples, buffer_format
  writer.write buffer
end

`afplay a.wav`
