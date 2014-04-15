package utils;

import java.io.BufferedInputStream;
import java.io.BufferedOutputStream;
import java.io.IOException;
import java.io.InputStream;
import java.io.OutputStream;

import org.eclipse.imp.pdb.facts.ISourceLocation;
import org.eclipse.imp.pdb.facts.IValueFactory;
import org.rascalmpl.interpreter.IEvaluatorContext;
import org.rascalmpl.interpreter.utils.RuntimeExceptionFactory;

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
}
