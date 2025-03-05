package rars.api;

public class Options {
    public boolean pseudo; // pseudo instructions allowed in source code or not.
    public boolean warningsAreErrors; // Whether assembler warnings should be considered errors.
    public boolean startAtMain; // Whether to start execution at statement labeled 'main'
    public boolean selfModifyingCode; // Whether to allow self-modifying code (e.g. write to text segment)
    public boolean exitOnEbreak; // Whether to exit on ebreak
    public int maxSteps;

    public Options() {
        pseudo = true;
        warningsAreErrors = false;
        startAtMain = false;
        selfModifyingCode = false;
        exitOnEbreak = false;
        maxSteps = -1;
    }
}
