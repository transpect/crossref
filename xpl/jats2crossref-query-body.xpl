<?xml version="1.0" encoding="UTF-8"?>
<p:declare-step 
  xmlns:p="http://www.w3.org/ns/xproc"
  xmlns:c="http://www.w3.org/ns/xproc-step"
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:crq="http://www.crossref.org/qschema/2.0"
  xmlns:jats="http://jats.nlm.nih.gov"
  version="1.0"
  name="query-body"
  type="jats:crossref-query-body">
  
  <p:input port="source" primary="true">
    <p:documentation>HoBoTS or BITS document</p:documentation>
  </p:input>
  <p:output port="result" primary="true">
    <p:documentation>A crossref query element that will later be wrapped in the request body etc.</p:documentation>
  </p:output>
  <p:output port="xslt">
    <p:pipe step="generate-xsl" port="result"/>
  </p:output>
  
  <p:option name="xpath" select="'/*'" required="false"/>
  
  <p:add-attribute name="generate-xsl" match="xsl:template[@name eq 'main']//xsl:apply-templates"
    attribute-name="select">
    <p:with-option name="attribute-value" select="$xpath"/>
    <p:input port="source">
      <p:document href="../xsl/jats2query-body.xsl"/>
    </p:input>
  </p:add-attribute>
  
  <p:sink/>
  
  <p:xslt name="transform" template-name="main">
    <p:input port="parameters"><p:empty/></p:input>
    <p:input port="stylesheet">
      <p:pipe step="generate-xsl" port="result"/>
    </p:input>
    <p:input port="source">
      <p:pipe port="source" step="query-body"/>
    </p:input>
  </p:xslt>
  
</p:declare-step>