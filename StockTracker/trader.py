import numpy as np
import pandas as pd
import yfinance as yf
import datetime
import matplotlib.pyplot as plt


class Trader:
    def __init__(self, tickers):
        self.tickers = tickers
        self.data = self.get_data()

    def get_data(self, period='1mo', interval='1h'):
        """
        Grabs data from Yahoo Finance
        :param interval:
        :param period:
        :return:
        """
        data = yf.download(tickers=self.tickers,
                           period=period,
                           interval=interval)
        data = data.reset_index()
        data.insert(7, "Seven Day Avg", [0] * len(data), True)

        return data

    def graph_data(self):
        plt.plot(self.data["index"], self.data["Seven Day Avg"], color="g")
        plt.bar(self.data["index"], self.data["Low"])
        plt.ylim(bottom=min(self.data["High"])*0.9)
        plt.show()

    def get_seven_day_avg(self):
        avgs = [0] * 7
        for row in self.data.index:
            avgs[row % 7] = (self.data.loc[row, "High"] + self.data.loc[row, "Low"]) / 2
            if 0 in avgs:
                self.data.loc[row, "Seven Day Avg"] = self.data.loc[row, "Low"]
            else:
                self.data.loc[row, "Seven Day Avg"] = sum(avgs) / 7

    def simulate(self, date):
        """
        Simulates a trader over a long period of time
        :param date:
        :return:
        """
        pass

    def simple_trader(self, end_date=datetime.datetime.today() + datetime.timedelta(days=1)):
        """
        Uses 7-day moving averages to determine when to trade
        :param end_date:
        :return:
        """
        pass


if __name__ == "__main__":
    trade = Trader(tickers="UBER")
    trade.get_seven_day_avg()
    trade.graph_data()
