#!/usr/bin/env python
# -*- coding: utf-8 -*-

from wsgiref.handlers import CGIHandler
from application import app

if __name__ == '__main__':
	CGIHandler().run(app)