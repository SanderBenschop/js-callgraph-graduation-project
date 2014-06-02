package utils;

import java.io.BufferedInputStream;
import java.io.BufferedOutputStream;
import java.io.IOException;
import java.io.InputStream;
import java.io.OutputStream;

import org.eclipse.imp.pdb.facts.ISourceLocation;
import org.eclipse.imp.pdb.facts.IString;
import org.eclipse.imp.pdb.facts.IValueFactory;
import org.rascalmpl.interpreter.IEvaluatorContext;
import org.rascalmpl.interpreter.utils.RuntimeExceptionFactory;
import org.rascalmpl.values.ValueFactoryFactory;

public class JavaUtils {

    private final IValueFactory values;
    
    public JavaUtils(IValueFactory values) {
        super();
        this.values = values;
    }

    public void copyFile(ISourceLocation sourceLoc, ISourceLocation targetLoc, IEvaluatorContext ctx) {
        try (InputStream in = new BufferedInputStream(ctx.getResolverRegistry().getInputStream(sourceLoc.getURI()))) {
            try (OutputStream out = new BufferedOutputStream(ctx.getResolverRegistry().getOutputStream(targetLoc.getURI(), false))) {
                int b;
                while ((b = in.read()) !=  -1) out.write(b);
            }
        } catch (IOException e) {
            throw RuntimeExceptionFactory.io(values.string(e.getMessage()), ctx.getCurrentAST(), null);
        }
    }
    
    public IString executeSloc(IString path, IEvaluatorContext ctx) {
        String commandString = "sloc";
        String[] args = new String[]{ commandString, path.getValue() };
        try (java.util.Scanner s = new java.util.Scanner(Runtime.getRuntime().exec(args).getInputStream())) {
            java.util.Scanner delimited = s.useDelimiter("\\A");
            return toIString(delimited.hasNext() ? delimited.next() : "");
        } catch(IOException e) {
            throw new RuntimeException(e);
        }
    }
    
    public IString regexReplace(IString source, IString pattern, IString replacement, IEvaluatorContext ctx) {
        String sourceValue = source.getValue(), 
               patternValue = pattern.getValue(),
               replacementValue = replacement.getValue();
        return toIString(sourceValue.replaceAll(patternValue, replacementValue));
    }
    
    private IString toIString(String string) {
        return ValueFactoryFactory.getValueFactory().string(string);
    }
}
