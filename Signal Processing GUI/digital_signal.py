#!/usr/bin/env python

import scipy
from scipy import fft
import scipy.io.wavfile
import numpy as np


class DigitalSignal:

    def __init__(self, my_array, sampling_frequency):
        self.subset_values = []
        self.sampling_frequency = sampling_frequency  # passed in sampling freq
        self.source_data = my_array  # numpy array
        self.filtered_data = my_array.copy()  # copy of numpy array
        self.freq_low = 0  # low frequency initialized to 0
        self.freq_high = sampling_frequency / 2  # high frequency initialized to Nyquist freq
        self.length = self.source_data.shape[0] / self.sampling_frequency  # length in seconds
        self.frequencies = scipy.fft.rfftfreq(len(self.source_data), d=1./self.sampling_frequency)  # frequency values
        # associated with each element of FFT

    @classmethod
    def from_wav(cls, file):
        """
        This class method reads in a wav file and returns the data and sampling frequency of file
        :param file: passed in .wav file
        :return: numpy array of data and sampling frequency as an int
        """
        sampling_frequency, my_array = scipy.io.wavfile.read(file, mmap=False)
        return cls(my_array, sampling_frequency)

    def bandpass(self, low=0, high=None):
        """
        This method filters the audio data via a bandpass filter
        :param low: low end of frequency filter
        :param high: high end of frequency filter
        :return: frequencies within the range provided
        """

        if high is None:
            high = self.sampling_frequency/2

        my_fft = scipy.fft.rfft(self.source_data)  # FFT of audio data

        # set any frequencies out of range to zero:
        for i, x in enumerate(self.frequencies):
            if x < low or x > high:
                my_fft[i] = 0
        self.freq_low = low
        self.freq_high = high
        self.filtered_data = scipy.fft.irfft(my_fft).astype(np.int16)

    def subset_signal(self, start=0, end=None):
        """
        This method sorts audio signal data based on the time frame we are wanting to observe
        :param start: starting position of audio signal data
        :param end: ending position of audio signal data
        :return: audio signal data between the range of start and end
        """
        self.subset_values = []
        if end is None:
            end = self.length

        # Indexing the desired times:
        filtered_times = []
        for i in range(len(self.filtered_data)):
            if i == 0:
                filtered_times.append(0)
            else:
                filtered_times.append(i / self.sampling_frequency)

        # Building array of audio signal data in the range of desired times:
        for i in range(len(self.filtered_data)):
            if start <= filtered_times[i] <= end:
                self.subset_values.append(self.filtered_data[i])

        return self.subset_values

    def save_wav(self, file_name, start=0, end=None):
        """
        This method simply saves out the data collected in subset_signal to an audio file
        :param file_name: name of audio file
        :param start: start time of desired audio signal range
        :param end: end time of desired audio signal range
        :return: writes out the currently saved filtered audio signal with the corresponding time bounds to the filename
        """
        data = self.filtered_data
        if end is None:
            end = self.length
        sample_rate = self.sampling_frequency
        scipy.io.wavfile.write(file_name, sample_rate, data)


if __name__ == "__main__":
    my_sig = DigitalSignal.from_wav("starwars.wav")
    my_sig.save_wav("test.wav")
