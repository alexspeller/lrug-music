require 'bundler'
Bundler.require

twelth_root_of_two = (2 ** (1.0/12))

current = 220.0
note_frequencies = [current]
12.times do
  current *= twelth_root_of_two
  note_frequencies.push current
end

sample_rate       = 22050 # frames per second
note_duration     = 0.5    # seconds
frames_per_note   = (sample_rate * note_duration).to_i

samples = []

note_frequencies.each do |frequency|
  cycles_per_frame = frequency / sample_rate
  increment = 2 * Math::PI * cycles_per_frame
  phase = 0

  frames_per_note.times.map do
    samples << Math.sin(phase)
    phase += increment
  end
end

filename = 'c.wav'

format = WaveFile::Format.new :mono, :pcm_16, sample_rate
buffer_format = WaveFile::Format.new :mono, :float, sample_rate
WaveFile::Writer.new filename, format do |writer|
  buffer = WaveFile::Buffer.new samples, buffer_format
  writer.write buffer
end

`afplay c.wav`
