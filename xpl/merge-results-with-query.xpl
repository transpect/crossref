<?xml version="1.0" encoding="UTF-8"?>
<p:declare-step 
  xmlns:p="http://www.w3.org/ns/xproc"
  xmlns:c="http://www.w3.org/ns/xproc-step"
  xmlns:cx="http://xmlcalabash.com/ns/extensions"
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:crq="http://www.crossref.org/qschema/2.0"
  xmlns:crqr="http://www.crossref.org/qrschema/2.0"
  xmlns:jats="http://jats.nlm.nih.gov"
  version="1.0"
  name="merge-results-with-query"
  type="crq:merge-results-with-query">
  
  <p:input port="source" primary="true">
    <p:documentation>CrossRef query results</p:documentation>
  </p:input>
  <p:input port="qb" sequence="true">
    <p:documentation>The query body that was posted to Crossref.
    If no document is supplied on this port, it is expected that the merging stylesheet
    uses the params document in order to locate the stored query batch document.
    If more than one document is supplied, only the first will be used.
    </p:documentation>
  </p:input>
  <p:input port="merging-stylesheet">
    <p:documentation>As a default, you may use ../xsl/merge-results-with-query.xsl
    Please note that it will rely on the transpect parameter work-path if no qb
    document is supplied.
    </p:documentation>
  </p:input>
  <p:input port="params" kind="parameter" primary="true">
    <p:documentation>Parameters that will be passed to the stylesheet and may or may not be used. 
      For example, the transpect paths document with the work-path parameter.</p:documentation>
  </p:input>
  <p:output port="result" primary="true">
    <p:documentation>The results, augmented with the initial unstructured_citations</p:documentation>
  </p:output>
  
  <p:xslt name="merge">
    <p:input port="stylesheet">
      <p:pipe port="merging-stylesheet" step="merge-results-with-query"/>
    </p:input>
    <p:input port="source">
      <p:pipe port="source" step="merge-results-with-query"/>
      <p:pipe port="qb" step="merge-results-with-query"/>
    </p:input>
  </p:xslt>
  
  <p:sink/>
  
  <p:for-each name="store">
    <p:iteration-source>
      <p:pipe step="merge" port="secondary"/> 
    </p:iteration-source>
    <p:store>
      <p:with-option name="href" select="base-uri()"/>
    </p:store>
    <p:xslt name="jsx" initial-mode="foo">
      <p:input port="parameters"><p:empty/></p:input>
      <p:input port="stylesheet">
        <p:document href="../xsl/build-crossref-doi-javascript.xsl"/>
      </p:input>
      <p:input port="source">
        <p:pipe port="current" step="store"/>  
      </p:input>
    </p:xslt>
    <p:store method="text" name="store-jsx">
      <p:with-option name="href" select="replace(base-uri(), 'xml$', 'jsx')">
        <p:pipe port="current" step="store"/>
      </p:with-option>
    </p:store>
  </p:for-each>
  
  <p:identity name="all-output">
    <p:input port="source">
      <p:pipe port="result" step="merge"/>
      <p:pipe port="secondary" step="merge"/>
    </p:input>
  </p:identity>
  
</p:declare-step>