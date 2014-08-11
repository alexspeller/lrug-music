require 'bundler'
Bundler.require

twelth_root_of_two = (2 ** (1.0/12))

current = 220.0
note_frequencies = [current]
50.times do
  current *= twelth_root_of_two
  note_frequencies.push current
end

T = 2
S = 1


scale_pattern   = [T, T, S, T, T, T, S]
current = 0
all_notes       = [note_frequencies.first]

scale_pattern.in_groups_of(2, false) do |group|
  current += group.sum
  all_notes << note_frequencies[current]
end

sample_rate       = 22050  # frames per second
note_duration     = 3    # seconds
frames_per_note   = (sample_rate * note_duration).to_i

samples = []

all_notes.each do |frequency|
  cycles_per_frame  = frequency / sample_rate
  increment         = 2 * Math::PI * cycles_per_frame
  phase             = 0

  frames_per_note.times.map do |i|
    # This time we add the samples to play multiple notes
    samples[i] ||= 0
    samples[i] += Math.sin(phase)
    phase += increment
  end
end

# Normalize the samples as the maximum can be above 1 now
max = samples.map{ |s| s.abs }.max
multiplier = 1.0 / max
samples.map!{ |s| multiplier * s }

filename = 'h.wav'

format = WaveFile::Format.new :mono, :pcm_16, sample_rate
buffer_format = WaveFile::Format.new :mono, :float, sample_rate
WaveFile::Writer.new filename, format do |writer|
  buffer = WaveFile::Buffer.new samples, buffer_format
  writer.write buffer
end

`afplay h.wav`
