import java.io.*;
import java.util.*;

public class $(FNOEXT) {
    public static void main(String[] args) throws IOException {
        BufferedReader br = new BufferedReader(new InputStreamReader(System.in));
        StringBuilder out = new StringBuilder();
        StreamTokenizer in = new StreamTokenizer(br);

        // int t = nextInt(in);
        int t = 1;
        while (t-- > 0) {
            solve(in, out);
        }
        System.out.print(out);
    }

    static void solve(StreamTokenizer in, StringBuilder out) throws IOException {

    }

    static int nextInt(StreamTokenizer in) throws IOException { in.nextToken(); return (int) in.nval; }
    static long nextLong(StreamTokenizer in) throws IOException { in.nextToken(); return (long) in.nval; }
    static String nextStr(StreamTokenizer in) throws IOException { in.nextToken(); return in.sval; }
}
