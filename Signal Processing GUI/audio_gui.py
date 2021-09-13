#!/usr/bin/env python

from digital_signal import DigitalSignal

from PyQt5.QtWidgets import QApplication, QMainWindow, QWidget, QVBoxLayout, QHBoxLayout, QPushButton, QSlider, QLabel, QLineEdit
from PyQt5.QtCore import Qt

from matplotlib.backends.backend_qt5agg import FigureCanvasQTAgg as FigureCanvas
from matplotlib.figure import Figure
import matplotlib.pyplot as plt

import numpy as np
from random import random
import scipy


class Interface(QMainWindow):
    def __init__(self):
        QMainWindow.__init__(self)

        self.setWindowTitle('Audio Filter Interface')

        # Initialize loading in a file
        self.loadLab = QPushButton("Load File:")
        self.loadLab.clicked.connect(self.load_button)
        self.load = QLineEdit("")
        self.file_name = "starwars.wav"

        self.my_dat = DigitalSignal.from_wav(self.file_name)

        self.nyquist = self.my_dat.freq_high
        self.endMax = self.my_dat.length

        # Low End Slider
        self.low = QSlider(Qt.Horizontal)
        self.low.setRange(0, round(self.nyquist))
        self.lowVal = 0
        self.low.setValue(self.lowVal)
        self.low.valueChanged.connect(self.lowValue)
        self.lowLab = QLabel("Low: " + str(self.lowVal))

        # High End Slider
        self.high = QSlider(Qt.Horizontal)
        self.high.setRange(0, round(self.nyquist))
        self.highVal = self.nyquist
        self.high.setValue(round(self.highVal))
        self.high.valueChanged.connect(self.highValue)
        self.highLab = QLabel("High: " + str(self.highVal))

        # Start Text Box
        self.start = QLineEdit("0")
        self.startLab = QLabel("Start:")
        self.prevStart = self.start.text()
        self.start.editingFinished.connect(self.graph)

        # End Text Box
        self.end = QLineEdit(str(self.endMax))
        self.endLab = QLabel("End:")
        self.end.editingFinished.connect(self.graph)

        # Reset Button
        reset_button = QPushButton('Reset All')
        reset_button.clicked.connect(self.resetFunc)

        # Save Button
        self.saveLab = QPushButton("Save File:")
        self.saveLab.clicked.connect(self.save_button)
        self.save = QLineEdit("")

        # The display for the graph
        self.figure = Figure()
        self.display = FigureCanvas(self.figure)
        self.figure.clear()
        self.graph()

        # A widget to hold everything
        widget = QWidget()
        self.setCentralWidget(widget)

        # Add layouts
        top_layout = QVBoxLayout()
        widget.setLayout(top_layout)

        slider_layout = QHBoxLayout()
        startend_layout = QHBoxLayout()
        load_layout = QHBoxLayout()
        save_layout = QHBoxLayout()
        top_layout.addLayout(slider_layout)
        top_layout.addLayout(startend_layout)
        top_layout.addLayout(load_layout)
        top_layout.addLayout(save_layout)

        top_layout.addWidget(self.display)

        # Adding Widgets
        slider_layout.addWidget(self.low)
        slider_layout.addWidget(self.lowLab)
        slider_layout.addWidget(self.high)
        slider_layout.addWidget(self.highLab)

        startend_layout.addWidget(self.startLab)
        startend_layout.addWidget(self.start)
        startend_layout.addWidget(self.endLab)
        startend_layout.addWidget(self.end)
        startend_layout.addWidget(reset_button)

        load_layout.addWidget(self.loadLab)
        load_layout.addWidget(self.load)

        save_layout.addWidget(self.saveLab)
        save_layout.addWidget(self.save)

    def load_button(self):
        try:
            self.my_dat = DigitalSignal.from_wav(self.load.text())
        except:
            print("File does not exist")
        self.lowVal = 0
        self.low.setValue(round(self.lowVal))
        self.highVal = self.nyquist
        self.high.setValue(round(self.highVal))
        self.graph()

    def save_button(self):
        self.my_dat.save_wav(self.save.text(),
                             start=self.start.text(),
                             end=self.end.text())

    def lowValue(self):
        self.lowVal = self.low.value()
        self.lowLab.setText("Low: {0}".format(self.lowVal))
        self.my_dat.bandpass(low=self.lowVal)
        self.graph()

    def highValue(self):
        self.highVal = self.high.value()
        self.highLab.setText("High: {0}".format(self.highVal))
        self.my_dat.bandpass(high=self.highVal)
        self.graph()

    def resetFunc(self):
        # Reset High Value
        self.highVal = self.nyquist
        self.high.setValue(self.highVal)
        self.high.valueChanged.connect(self.highValue)

        # Reset Low Value
        self.lowVal = 0
        self.low.setValue(self.lowVal)
        self.low.valueChanged.connect(self.lowValue)

        self.my_dat = DigitalSignal.from_wav(self.file_name)
        self.figure.clear()
        self.graph()

    def graph(self):
        try:
            float(self.start.text()) and float(self.end.text())
        except:
            self.start.setText("0")
            self.end.setText(str(self.endMax))
        plot_data = self.my_dat.subset_signal(start=float(self.start.text()),
                                              end=float(self.end.text()))
        self.draw(plot_data)

    def draw(self, data):
        x = np.linspace(float(self.start.text()),
                        float(self.end.text()),
                        len(data))
        self.figure.clear()
        ax = self.figure.add_subplot(111)
        ax.plot(x, data)
        ax.set_title('Graph')
        ax.set_xlabel('Time')
        ax.set_ylabel('Frequency')
        self.display.draw()


if __name__ == '__main__':
    app = QApplication([])

    interface = Interface()

    interface.show()

    app.exec_()
