#!/usr/bin/env python
# -*- coding: utf-8 -*-

import logging
import json

from werkzeug.routing import Map, Rule
from werkzeug.wrappers import Response, Request
from werkzeug.exceptions import HTTPException, NotFound
from werkzeug.utils import redirect
from jinja2 import Environment, FileSystemLoader

from models import ContentModel

class iOSExample(object):
	def __init__(self, importName, templateFolder='templates'):
		self.importName = importName
		self.templateFolder = templateFolder
		self.jinjaEnv = Environment(loader=FileSystemLoader(self.templateFolder))
		self.gotFirstRequest=False
		self.router = Map([
				Rule('/',endpoint='index'),
				Rule('/<int:id>', endpoint='show'),
				Rule('/admin', endpoint='admin'),
				Rule('/admin/add', endpoint='add'),
				Rule('/admin/del/<int:id>', endpoint='delete')
			])

	def indexHandler(self, request):
		mds = ContentModel.all().fetch(limit=5)
		entries = [{'id': ent.key().id()} for ent in mds]

		return self.renderTemplate('index.html', entries=entries)

	def showHandler(self, request, id):
		if 'X-Requested-With' in request.headers:
			entry = ContentModel.get_by_id(id)
			if entry:
				data = {'id':entry.key().id(), 'title':entry.title, 'content':entry.content}
				data = json.dumps(data)
			else:
				data = json.dumps({'id':0,'title':'not found', 'content':'not found'})
			return Response(data,mimetype="application/json")
		else:
			if not self.gotFirstRequest:
				return self.indexHandler(request)	
			return self.renderTemplate('index.html')

	def adminHandler(self, request):
		dbs = ContentModel.all().fetch(limit=5)
		contents = []
		for entry in dbs:
			contents.append({'id':entry.key().id(), 'title':entry.title, 'content':entry.content})
		return self.renderTemplate('admin.html', contents=contents)

	def addHandler(self, request):
		model = ContentModel()
		model.title = request.form['title']
		model.content = request.form['content']

		try:
			model.put()
			return redirect('/admin')
		except Exception, e:
			return e

	def deleteHandler(self, request, id):
		model = ContentModel.get_by_id(id)
		if model:
			try:
				model.delete()
			except:
				return e
		return redirect('/admin')

	def error404(self):
		response = self.renderTemplate('404.html')
		response.satus_code = 404
		return response

	def renderTemplate(self, templateName, **context):
		t = self.jinjaEnv.get_template(templateName)
		if not self.gotFirstRequest:
				self.gotFirstRequest= True
		return Response(t.render(context), mimetype="text/html")

	def dispatchRequest(self,request):
		adapter = self.router.bind_to_environ(request.environ)
		try:
			endpoint, values = adapter.match()
			# return self.controllers[rule.endpoint](**request.args)
			return getattr(self, endpoint + 'Handler')(request, **values)
		except NotFound, e:
			return self.error404()
		except HTTPException, e:
			return e

	def wsgiApp(self,environ, startResponce):
		request = Request(environ)
		response = self.dispatchRequest(request)
		return response(environ, startResponce)

	def __call__(self, environ, startResponce):
		return self.wsgiApp(environ, startResponce)


app = iOSExample(__name__)