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


all_chords       = []
current_mode    = [T, T, S, T, T, T, S]
current_start   = 0

8.times do
  current = current_start
  chord_frequencies = [note_frequencies[current]]
  current_mode.in_groups_of(2, false) do |group|
    current += group.sum
    chord_frequencies.push note_frequencies[current]
  end

  all_chords      << chord_frequencies
  current_start   += current_mode.first

  current_mode.rotate!
end


sample_rate       = 22050 # frames per second
note_duration     = 1.5    # seconds
frames_per_note   = (sample_rate * note_duration).to_i

samples = []

all_chords.each_with_index do |chord, i|
  chord_start_frame = i * note_duration * sample_rate
  chord.each do |frequency|
    cycles_per_frame  = frequency / sample_rate
    increment         = 2 * Math::PI * cycles_per_frame
    phase             = 0

    frames_per_note.times.map do |j|
      # This time we add the samples to play multiple notes
      samples[chord_start_frame + j] ||= 0
      samples[chord_start_frame + j] += Math.sin(phase)
      phase += increment
    end
  end
end

# Normalize the samples as the maximum can be above 1 now
max = samples.map{ |s| s.abs }.max
multiplier = 1.0 / max
samples.map!{ |s| multiplier * s }


filename = 'i.wav'

format = WaveFile::Format.new :mono, :pcm_16, sample_rate
buffer_format = WaveFile::Format.new :mono, :float, sample_rate
WaveFile::Writer.new filename, format do |writer|
  buffer = WaveFile::Buffer.new samples, buffer_format
  writer.write buffer
end

`afplay i.wav`
