#!/usr/bin/env python
# -*- coding: utf-8 -*-

from google.appengine.ext import db

class ContentModel(db.Model):
	title = db.StringProperty()
	content = db.TextProperty()
