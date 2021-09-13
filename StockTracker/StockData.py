import yfinance as yf
import matplotlib.pyplot as plt
import pandas as pd


class StockTracker:
    def __init__(self):
        self.tickers = ['UBER']
        self.period = '5d'
        self.interval = '1d'

    def getData(self):
        data = yf.download(tickers = self.tickers[0], period=self.period, interval=self.interval)
        print(data)


if __name__ == '__main__':
    track = StockTracker()
    track.getData()
