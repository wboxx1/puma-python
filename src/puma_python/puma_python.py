# -*- coding: utf-8 -*-

"""Main module."""
from kivy.app import App
from kivy.uix.widget import Widget
from kivy.uix.gridlayout import GridLayout
from kivy.uix.button import Button
from kivy.properties import NumericProperty, ReferenceListProperty, ObjectProperty
from kivy.vector import Vector
from kivy.clock import Clock
from random import randint

class WelcomePage(GridLayout):

    def __init__(self, **kwargs):
        super(WelcomePage, self).__init__(**kwargs)
        self.cols = 2
        self.add_widget(Button(text="Survey"))
        self.add_widget(Button(text="Replay"))
        self.add_widget(Button(text="Mission"))
        self.add_widget(Button(text="Configs"))

class PumaApp(App):
    def build(self):        
        return WelcomePage()


if __name__ == '__main__':
    PumaApp().run()