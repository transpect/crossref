<?xml version="1.0" encoding="UTF-8"?>
<p:declare-step 
  xmlns:p="http://www.w3.org/ns/xproc"
  xmlns:c="http://www.w3.org/ns/xproc-step"
  xmlns:cx="http://xmlcalabash.com/ns/extensions" 
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:xs="http://www.w3.org/2001/XMLSchema"
  xmlns:crq="http://www.crossref.org/qschema/2.0"
  version="1.0"
  name="wrap-query"
  type="crq:wrap-query">
  
  <p:input port="source" primary="true">
    <p:documentation>crq:body of a crq:query-batch</p:documentation>
  </p:input>
  <p:output port="qb">
    <p:documentation>crq:query-batch</p:documentation>
    <p:pipe port="result" step="wrap"></p:pipe>
  </p:output>
  <p:output port="result" primary="true">
    <p:documentation>the result message of crossref’s web service</p:documentation>
  </p:output>
  <p:option name="email" required="true"/>
  <p:option name="batch-id" required="true"/>
  <p:option name="user" required="true"/>
  <p:option name="pass" required="true"/>
  <p:option name="fire" required="false" select="'true'"/>
  
  <p:import href="http://xmlcalabash.com/extension/steps/library-1.0.xpl" />
  
  <p:xslt name="wrap">
    <p:input port="parameters"><p:empty/></p:input>
    <p:with-param name="email" select="$email"/>
    <p:with-param name="batch-id" select="$batch-id"/>
    <p:input port="stylesheet">
      <p:inline>
        <xsl:stylesheet version="2.0">
          <xsl:param name="email" as="xs:string"/>
          <xsl:param name="batch-id" as="xs:string"/>
          <xsl:template match="/">
            <query_batch xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" version="2.0" 
              xmlns="http://www.crossref.org/qschema/2.0" 
              xsi:schemaLocation="http://www.crossref.org/qschema/2.0 http://www.crossref.org/qschema/crossref_query_input2.0.xsd">
              <head>
                <email_address>
                  <xsl:value-of select="$email"/>
                </email_address>
                <doi_batch_id>
                  <xsl:value-of select="$batch-id"/>
                </doi_batch_id>
              </head>
              <xsl:sequence select="*"/>
            </query_batch>
          </xsl:template>
        </xsl:stylesheet>
      </p:inline>
    </p:input>
  </p:xslt>  
  
  <p:validate-with-xml-schema>
    <p:with-option name="assert-valid" select="$fire"/>
    <p:input port="schema">
      <p:document href="../xsd/crossref_query_input2.0.xsd"/>
    </p:input>
  </p:validate-with-xml-schema>
  
  <p:sink/>
  
  <p:in-scope-names name="vars"/>
  
  <p:template name="http-request">
    <p:input port="template">
      <p:inline>
        <c:request 
          method="POST" 
          href="https://doi.crossref.org/servlet/deposit?operation=doQueryUpload&amp;login_id={$user}&amp;login_passwd={$pass}">
          <c:multipart content-type="multipart/form-data" boundary="=-=-=-=-=">
            <c:body content-type="application/xml" disposition='form-data; name="fname"; filename="hobots-refs.xml"'>
              {/*}
            </c:body>
          </c:multipart>
        </c:request>
      </p:inline>
    </p:input>
    <p:input port="source">
      <p:pipe step="wrap" port="result"/>
    </p:input>
    <p:input port="parameters">
      <p:pipe step="vars" port="result"/>
    </p:input>
  </p:template>
  
  <p:choose>
    <p:when test="$fire = 'true'">
      <p:http-request omit-xml-declaration="false" encoding="US-ASCII"/>    
    </p:when>
    <p:otherwise>
      <p:identity>
        <p:input port="source">
          <p:inline><c:ok/></p:inline>  
        </p:input>
      </p:identity>
    </p:otherwise>
  </p:choose>
  

</p:declare-step>
