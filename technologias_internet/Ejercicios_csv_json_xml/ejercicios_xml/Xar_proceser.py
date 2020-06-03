#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Created on Thu May  7 16:24:09 2020

@author: Pedro_Martínez
"""

import xml.sax

class NewssRSS( xml.sax.ContentHandler):
    # Definimos los atributos propios
    def __init__(self):
        self.title = ""
        self.link = ""
        self.description = ""
        self.count = 0
        self.Datos = ""
    
    def startElement(self,etiqueta, atributos):
        self.Datos = etiqueta
            
    def endElement(self,etiqueta):
        
        if self.Datos == "title":
            print("Titulo:",self.title)
        elif self.Datos== "link":
            print("Link:", self.link)
        elif self.Datos == "description":
            print("Descripcion:", self.description)
            if self.count == 0:
                print("Cabecera\n")
            else:
                print(f'subtitular nº {self.count}\n')
            self.count+=1
        else:
            pass
        

        # Reiniciamos la variable para que la siguiente vuelva a tomar el nombre de la etiqueta
        self.Datos = ""
        
    def characters(self, contenido):
        # Si el nombre es titulo la etiqueta cambiará a titulo y en endElement
        #   imprimiremos su valor
        if self.Datos == "title":
            self.title = contenido
        elif self.Datos == "link":
            self.link = contenido
        elif self.Datos == "description":
            self.description = contenido
        else:
            pass
            
    def startDocument(self):
        print('----------------------------------------')
        print('Comienzo en el procesamiento del archivo')
        print('----------------------------------------\n')
        
    def endDocument(self):
        print('----------------------------------------')
        print('Fin del procesamiento del archivo xml')
        print('----------------------------------------')
        
if ( __name__ == "__main__"):
    # Crear un XMLReader
    parser=xml.sax.make_parser()
    # Deshabilitar namespaces
    parser.setFeature(xml.sax.handler.feature_namespaces,0)
    #Sobre escribir el default default ContextHandler
    Handler=NewssRSS()
    
    parser.setContentHandler(Handler)
    parser.parse("rss.xml") 