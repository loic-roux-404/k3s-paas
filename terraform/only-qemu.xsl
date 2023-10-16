<?xml version="1.0" ?>
    <xsl:stylesheet version="1.0"
                    xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
    <xsl:output omit-xml-declaration="yes" indent="yes"/>

    <!-- Copy everything from the generated XML -->
    <xsl:template match="node()|@*">
        <xsl:copy>
        <xsl:apply-templates select="node()|@*"/>
        </xsl:copy>
    </xsl:template>

    <!-- Set domain#type to 'qemu' for nested virtualization -->
    <xsl:template match="/domain/@type">
        <xsl:attribute name="type">
            <xsl:value-of select="'hvf'"/>
        </xsl:attribute>
    </xsl:template>
</xsl:stylesheet>