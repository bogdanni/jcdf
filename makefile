
JAVAC = javac
JAVA = java
JAR = jar
JAVADOC = javadoc

JARFILE = jcdf.jar

WWW_FILES = $(JARFILE) javadocs index.html cdflist.html cdfdump.html
WWW_DIR = /export/home/mbt/public_html/jcdf

TEST_JARFILE = jcdf_test.jar
TEST_CDFS = data/*.cdf

JSRC = \
       BankBuf.java \
       Buf.java \
       Bufs.java \
       Pointer.java \
       SimpleNioBuf.java \
       WrapperBuf.java \
       \
       AttributeDescriptorRecord.java \
       AttributeEntryDescriptorRecord.java \
       CdfDescriptorRecord.java \
       CompressedCdfRecord.java \
       CompressedParametersRecord.java \
       CompressedVariableValuesRecord.java \
       GlobalDescriptorRecord.java \
       Record.java \
       RecordFactory.java \
       RecordPlan.java \
       SparsenessParametersRecord.java \
       UnusedInternalRecord.java \
       VariableDescriptorRecord.java \
       VariableIndexRecord.java \
       VariableValuesRecord.java \
       CdfField.java \
       OffsetField.java \
       \
       BitExpandInputStream.java \
       Compression.java \
       NumericEncoding.java \
       RunLengthInputStream.java \
       RecordMap.java \
       DataReader.java \
       EpochFormatter.java \
       \
       AttributeEntry.java \
       CdfContent.java \
       GlobalAttribute.java \
       VariableAttribute.java \
       Variable.java \
       CdfInfo.java \
       CdfReader.java \
       DataType.java \
       Shaper.java \
       CdfFormatException.java \
       \
       CdfDump.java \
       CdfList.java \
       LogUtil.java \

TEST_JSRC = \
       ExampleTest.java \
       SameTest.java \

build: jar docs

jar: $(JARFILE)

docs: $(WWW_FILES)

javadocs: $(JSRC) package-info.java
	rm -rf javadocs
	mkdir javadocs
	$(JAVADOC) -quiet -d javadocs $(JSRC) package-info.java

index.html: jcdf.xhtml
	xmllint -noout jcdf.xhtml && \
	xmllint -html jcdf.xhtml >index.html

cdflist.html: $(JARFILE)
	./examples.sh \
            "java -classpath $(JARFILE) uk.ac.bristol.star.cdf.util.CdfList" \
            "-help" \
            "data/example1.cdf" \
            "-data data/example1.cdf" \
            >$@

cdfdump.html: $(JARFILE)
	./examples.sh \
            "java -classpath $(JARFILE) uk.ac.bristol.star.cdf.util.CdfDump" \
            "-help" \
            "data/example1.cdf" \
            "-fields -html data/example1.cdf" \
            >$@

installwww: $(WWW_DIR) $(WWW_FILES)
	rm -rf $(WWW_DIR)/* && \
	cp -r $(WWW_FILES) $(WWW_DIR)/

test: extest convtest

convtest: $(JARFILE) $(TEST_JARFILE) $(TEST_CDFS)
	rm -rf tmp; \
	mkdir tmp; \
	for f in $(TEST_CDFS); \
        do \
           files=`./cdfvar.sh -outdir tmp -report $$f`; \
           cmd="java -ea -classpath $(JARFILE):$(TEST_JARFILE) \
                     uk.ac.bristol.star.cdf.test.SameTest $$files"; \
           ./cdfvar.sh -outdir tmp -create $$f && \
           echo $$cmd && \
           $$cmd || \
           break; \
        done

extest: $(JARFILE) $(TEST_JARFILE)
	java -ea -classpath $(JARFILE):$(TEST_JARFILE) \
             uk.ac.bristol.star.cdf.test.ExampleTest \
             data/example1.cdf data/example2.cdf

clean:
	rm -rf $(JARFILE) $(TEST_JARFILE) tmp \
               index.html javadocs cdflist.html cdfdump.html

$(JARFILE): $(JSRC)
	rm -rf tmp
	mkdir -p tmp
	$(JAVAC) -Xlint:unchecked -d tmp $(JSRC) \
            && $(JAR) cf $@ -C tmp .
	rm -rf tmp

$(TEST_JARFILE): $(JARFILE) $(TEST_JSRC)
	rm -rf tmp
	mkdir -p tmp
	$(JAVAC) -Xlint:unchecked -d tmp -classpath $(JARFILE) $(TEST_JSRC) \
            && $(JAR) cf $@ -C tmp .
	rm -rf tmp

