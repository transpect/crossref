<?xml version="1.0" encoding="UTF-8"?>
<p:declare-step 
  xmlns:p="http://www.w3.org/ns/xproc"
  xmlns:c="http://www.w3.org/ns/xproc-step"
  xmlns:cx="http://xmlcalabash.com/ns/extensions" 
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:crq="http://www.crossref.org/qschema/2.0"
  xmlns:jats="http://jats.nlm.nih.gov"
  version="1.0"
  name="post-query">
  <p:input port="source" primary="true">
    <p:documentation>HoBoTS or BITS document</p:documentation>
  </p:input>
  <p:output port="result" primary="true">
    <p:documentation>The response to the Crossref post request. Note that this response will not
    contain looked up DOIs. They’ll be sent via email.</p:documentation>
  </p:output>
  <p:output port="qb">
    <p:documentation>crq:query-batch</p:documentation>
    <p:pipe port="qb" step="wrap"/>
  </p:output>
  <p:serialization port="qb" omit-xml-declaration="false" indent="true"/>
  
  <p:option name="xpath" required="false" select="'/*'"/>
  <p:option name="email" required="true"/>
  <p:option name="user" required="true"/>
  <p:option name="pass" required="true"/>
    
  <p:import href="http://xmlcalabash.com/extension/steps/library-1.0.xpl" />
  <p:import href="jats2crossref-query-body.xpl"/>
  <p:import href="wrap-query.xpl"/>
    
  <jats:crossref-query-body name="body">
    <p:with-option name="xpath" select="$xpath"/>
  </jats:crossref-query-body>
  
  <crq:wrap-query name="wrap">
    <p:with-option name="email" select="$email"/>
    <p:with-option name="user" select="$user"/>
    <p:with-option name="pass" select="$pass"/>
    <p:with-option name="batch-id" select="concat(replace(base-uri(), '^.+/', ''), '?timestamp=', current-dateTime())"/>
  </crq:wrap-query>
  

  
</p:declare-step>