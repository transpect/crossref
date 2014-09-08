<?xml version="1.0" encoding="UTF-8"?>
<p:declare-step 
  xmlns:p="http://www.w3.org/ns/xproc"
  xmlns:c="http://www.w3.org/ns/xproc-step"
  xmlns:cx="http://xmlcalabash.com/ns/extensions"
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:crq="http://www.crossref.org/qschema/2.0"
  xmlns:crqr="http://www.crossref.org/qrschema/2.0"
  xmlns:hobots="http://hobots.hogrefe.com/" 
  xmlns:jats="http://jats.nlm.nih.gov"
  version="1.0"
  name="process-results"
  type="crq:process-results">
  
  <p:option name="input-dir-uri">
    <p:documentation>Directory with crossref query result files (crossref_result
      xmlns="http://www.crossref.org/qrschema/2.0") </p:documentation>
  </p:option>
  <p:option name="tmp-suffix" required="false" select="''"/>
  
  <p:input port="conf">
    <p:documentation>A transpect configuration file.</p:documentation>
  </p:input>
  <p:input port="merging-stylesheet">
    <p:document href="../xsl/merge-results-with-query.xsl"/>
    <p:documentation>A stylesheet that receives the parameters and, in turn, each query result.</p:documentation>
  </p:input>
  <p:output port="result" primary="true" >
    <p:pipe port="result" step="files"/>
  </p:output>
  <p:serialization port="result" method="text" />

  <p:import href="http://xmlcalabash.com/extension/steps/library-1.0.xpl"/>
  <p:import href="merge-results-with-query.xpl"/>
  <p:import href="http://customers.le-tex.de/generic/book-conversion/adaptions/common/xpl/hobots-paths.xpl"/>
  
  <p:directory-list name="list-input-files" exclude-filter=".*\.txt.?">
    <p:with-option name="path" select="$input-dir-uri"/>
  </p:directory-list>

  <p:for-each name="iteration">
    <p:iteration-source select="/c:directory/c:file"/>
    <p:output port="result" primary="true">
      <p:pipe port="result" step="paths"/>
    </p:output>
    <p:load name="query-result">
      <p:with-option name="href" select="resolve-uri(/*/@name, base-uri())"/>
    </p:load>
    <p:sink/>
    <hobots:paths name="paths">
      <p:with-option name="pipeline" select="'process-crossref-results.xpl'"/>
      <p:with-option name="file" select="replace(/crqr:crossref_result/crqr:query_result/crqr:head/crqr:doi_batch_id, '\?.+$', '')">
        <p:pipe port="result" step="query-result"/>
      </p:with-option>
      <p:input port="conf">
        <p:pipe port="conf" step="process-results"/>
      </p:input>
    </hobots:paths>
    <p:sink/>
    <crq:merge-results-with-query name="merge">
      <p:input port="source">
        <p:pipe port="result" step="query-result"/>
      </p:input>
      <p:input port="qb"><p:empty/></p:input>
      <p:input port="merging-stylesheet">
        <p:pipe port="merging-stylesheet" step="process-results"/>
      </p:input>
      <p:input port="params">
        <p:pipe port="result" step="paths"/>
      </p:input>
      <p:with-option name="tmp-suffix" select="$tmp-suffix"/>
    </crq:merge-results-with-query>
    <p:sink/>
  </p:for-each>
  
  <p:xslt name="files" template-name="main">
    <p:input port="parameters"><p:empty/></p:input>
    <p:input port="stylesheet">
      <p:inline>
        <xsl:stylesheet version="2.0">
          <xsl:template name="main">
            
            <foo>
              <xsl:sequence select="string-join(
                                      distinct-values(
                                        for $ps in collection()/c:param-set
                                        return concat(
                                          replace($ps/c:param[@name eq 'work-path']/@value, '^file:/*?(/)(([a-z]:)/)?', '$3$1', 'i'), 
                                          'crossref/', 
                                          $ps/c:param[@name eq 'work-basename']/@value,
                                          '.crossref.xml'
                                        )
                                      ),
                                      '&#xa;'
                                    )"></xsl:sequence>  
            </foo>
          </xsl:template>
        </xsl:stylesheet>
      </p:inline>
    </p:input>
  </p:xslt>

</p:declare-step>
