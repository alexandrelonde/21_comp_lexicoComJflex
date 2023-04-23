enum Classe {
    cId,
    cInt,
    cReal,
    cPalRes,
    cDoisPontos,
    cAtribuicao,
    cMais,
    cMenos,
    cDivisao,
    cMultiplicacao,
    cMaior,
    cMenor,
    cMaiorIgual,
    cMenorIgual,
    cDiferente,
    cIgual,
    cVirgula,
    cPontoVirgula,
    cPonto,
    cParEsq,
    cParDir,
    cString,
    cEOF,
}


class Valor {
    private int valorInteiro;
    private double valorDecimal;
    private String valorIdentificador;

    public Valor() {
    }

    public Valor(double valorDecimal) {
        this.valorDecimal = valorDecimal;
    }

    public Valor(int valorInteiro) {
        this.valorInteiro = valorInteiro;
    }

    public Valor(String valorIdentificador) {
        this.valorIdentificador = valorIdentificador;
    }

    public int getValorInteiro() {
        return valorInteiro;
    }

    public void setValorInteiro(int valorInteiro) {
        this.valorInteiro = valorInteiro;
    }

    public double getValorDecimal() {
        return valorDecimal;
    }

    public void setValorDecimal(double valorDecimal) {
        this.valorDecimal = valorDecimal;
    }

    public String getValorIdentificador() {
        return valorIdentificador;
    }

    public void setValorIdentificador(String valorIdentificador) {
        this.valorIdentificador = valorIdentificador;
    }

    @Override
    public String toString() {
        return "Valor{" +
                "valorInteiro=" + valorInteiro +
                ", valorDecimal=" + valorDecimal +
                ", valorIdentificador='" + valorIdentificador + '\'' +
                '}';
    }
}

class Token {

    private Classe classe;
    private Valor valor;
    private int linha;
    private int coluna;

    public Token(int linha, int coluna, Classe classe) {
        this.linha = linha;
        this.coluna = coluna;
        this.classe = classe;
    }

    public Token(int linha, int coluna, Classe classe, Valor valor) {
        this.classe = classe;
        this.valor = valor;
        this.linha = linha;
        this.coluna = coluna;
    }

    public Classe getClasse() {
        return classe;
    }

    public void setClasse(Classe classe) {
        this.classe = classe;
    }

    public Valor getValor() {
        return valor;
    }

    public void setValor(Valor valor) {
        this.valor = valor;
    }

    public int getLinha() {
        return linha;
    }

    public void setLinha(int linha) {
        this.linha = linha;
    }

    public int getColuna() {
        return coluna;
    }

    public void setColuna(int coluna) {
        this.coluna = coluna;
    }

    @Override
    public String toString() {
        return "Token [classe: " + classe + ", " + valor + ", linha: " + linha + ", coluna: " + coluna + "]";
    }

}

%%

// %standalone
%class AnaliserLexico
// %function getToken
%type Token
%unicode
%line
%column
// %cup

DIGIT = [0-9]
LETTER = [A-Za-z]
INTEIRO = 0 | [1-9]{DIGIT}*
STRING = \"[^\"]*\"
REAL = {INTEIRO}\.{DIGIT}+
WORD = {LETTER}({LETTER}|{DIGIT})*|"and"|"array"|"begin"|"case"|"const"|"div"|"do"|"downto"|"else"|"end"|"file"|"for"|"function"|"goto"|"if"|"in"|"label"|"mod"|"nil"|"not"|"of"|"or"|"packed"|"procedure"|"program"|"record"|"repeat"|"set"|"then"|"to"|"type"|"until"|"var"|"while"|"with"
OPERATORS = ":="|">="|"<="|"<>"|"="|":"|"\+"|"-"|"/"|"*"|">"|"<"|","|";"|"."|"\(" | "\)"
ENDLINE = \r|\n|\r\n
SPACE = {ENDLINE} | [ \t\f]

%{
public static void main(String[] argv) {
    if (argv.length == 0) {
      System.out.println("Usage : java AnaliserLexico [ --encoding <name> ] <inputfile(s)>");
    }
    else {
      int firstFilePos = 0;
      String encodingName = "UTF-8";
      if (argv[0].equals("--encoding")) {
        firstFilePos = 2;
        encodingName = argv[1];
        try {
          // Side-effect: is encodingName valid?
          java.nio.charset.Charset.forName(encodingName);
        } catch (Exception e) {
          System.out.println("Invalid encoding '" + encodingName + "'");
          return;
        }
      }
      for (int i = firstFilePos; i < argv.length; i++) {
        AnaliserLexico scanner = null;
        java.io.FileInputStream stream = null;
        java.io.Reader reader = null;
        try {
          stream = new java.io.FileInputStream(argv[i]);
          reader = new java.io.InputStreamReader(stream, encodingName);
          scanner = new AnaliserLexico(reader);
          while ( !scanner.zzAtEOF ) {
            System.out.println(scanner.yylex());
          }
        }
        catch (java.io.FileNotFoundException e) {
          System.out.println("File not found : \""+argv[i]+"\"");
        }
        catch (java.io.IOException e) {
          System.out.println("IO error scanning file \""+argv[i]+"\"");
          System.out.println(e);
        }
        catch (Exception e) {
          System.out.println("Unexpected exception:");
          e.printStackTrace();
        }
        finally {
          if (reader != null) {
            try {
              reader.close();
            }
            catch (java.io.IOException e) {
              System.out.println("IO error closing file \""+argv[i]+"\"");
              System.out.println(e);
            }
          }
          if (stream != null) {
            try {
              stream.close();
            }
            catch (java.io.IOException e) {
              System.out.println("IO error closing file \""+argv[i]+"\"");
              System.out.println(e);
            }
          }
        }
      }
    }
  }
%}

%%

{SPACE}     { /* Ignorar */ }
{INTEIRO}       { return new Token(yyline + 1, yycolumn + 1, Classe.cInt, new Valor(Integer.parseInt(yytext()))); }
{STRING}        { return new Token(yyline + 1, yycolumn + 1, Classe.cString, new Valor(yytext())); }
{REAL}          { return new Token(yyline + 1, yycolumn + 1, Classe.cReal, new Valor(Double.parseDouble(yytext()))); }
{WORD} {
  switch (yytext()) {
    case "and":  return new Token(yyline + 1, yycolumn + 1, Classe.cPalRes, new Valor(yytext()));
    case "array": return new Token(yyline + 1, yycolumn + 1, Classe.cPalRes, new Valor(yytext()));
    case "begin":  return new Token(yyline + 1, yycolumn + 1, Classe.cPalRes, new Valor(yytext()));
    case "case":  return new Token(yyline + 1, yycolumn + 1, Classe.cPalRes, new Valor(yytext()));
    case "const":  return new Token(yyline + 1, yycolumn + 1, Classe.cPalRes, new Valor(yytext()));
    case "div": return new Token(yyline + 1, yycolumn + 1, Classe.cPalRes, new Valor(yytext()));
    case "do":  return new Token(yyline + 1, yycolumn + 1, Classe.cPalRes, new Valor(yytext()));
    case "downto":  return new Token(yyline + 1, yycolumn + 1, Classe.cPalRes, new Valor(yytext()));
    case "else": return new Token(yyline + 1, yycolumn + 1, Classe.cPalRes, new Valor(yytext()));
    case "end": return new Token(yyline + 1, yycolumn + 1, Classe.cPalRes, new Valor(yytext()));
    case "file": return new Token(yyline + 1, yycolumn + 1, Classe.cPalRes, new Valor(yytext()));
    case "for":  return new Token(yyline + 1, yycolumn + 1, Classe.cPalRes, new Valor(yytext()));
    case "function":  return new Token(yyline + 1, yycolumn + 1, Classe.cPalRes, new Valor(yytext()));
    case "goto":  return new Token(yyline + 1, yycolumn + 1, Classe.cPalRes, new Valor(yytext()));
    case "if":  return new Token(yyline + 1, yycolumn + 1, Classe.cPalRes, new Valor(yytext()));
    case "in":  return new Token(yyline + 1, yycolumn + 1, Classe.cPalRes, new Valor(yytext()));
    case "label": return new Token(yyline + 1, yycolumn + 1, Classe.cPalRes, new Valor(yytext()));
    case "mod": return new Token(yyline + 1, yycolumn + 1, Classe.cPalRes, new Valor(yytext()));
    case "nil": return new Token(yyline + 1, yycolumn + 1, Classe.cPalRes, new Valor(yytext()));
    case "not":  return new Token(yyline + 1, yycolumn + 1, Classe.cPalRes, new Valor(yytext()));
    case "of":  return new Token(yyline + 1, yycolumn + 1, Classe.cPalRes, new Valor(yytext()));
    case "or":  return new Token(yyline + 1, yycolumn + 1, Classe.cPalRes, new Valor(yytext()));
    case "packed":  return new Token(yyline + 1, yycolumn + 1, Classe.cPalRes, new Valor(yytext()));
    case "procedure":  return new Token(yyline + 1, yycolumn + 1, Classe.cPalRes, new Valor(yytext()));
    case "program":  return new Token(yyline + 1, yycolumn + 1, Classe.cPalRes, new Valor(yytext()));
    case "record":  return new Token(yyline + 1, yycolumn + 1, Classe.cPalRes, new Valor(yytext()));
    case "repeat": return new Token(yyline + 1, yycolumn + 1, Classe.cPalRes, new Valor(yytext()));
    case "set": return new Token(yyline + 1, yycolumn + 1, Classe.cPalRes, new Valor(yytext()));
    case "then": return new Token(yyline + 1, yycolumn + 1, Classe.cPalRes, new Valor(yytext()));
    case "to":  return new Token(yyline + 1, yycolumn + 1, Classe.cPalRes, new Valor(yytext()));
    case "type":  return new Token(yyline + 1, yycolumn + 1, Classe.cPalRes, new Valor(yytext()));
    case "until":  return new Token(yyline + 1, yycolumn + 1, Classe.cPalRes, new Valor(yytext()));
    case "var":  return new Token(yyline + 1, yycolumn + 1, Classe.cPalRes, new Valor(yytext()));
    case "while":  return new Token(yyline + 1, yycolumn + 1, Classe.cPalRes, new Valor(yytext()));
    case "with":  return new Token(yyline + 1, yycolumn + 1, Classe.cPalRes, new Valor(yytext()));
    default:  return new Token(yyline + 1, yycolumn + 1, Classe.cId, new Valor(yytext()));
  }
}
{OPERATORS} {
    switch (yytext()) {
        case ":=": return new Token(yyline + 1, yycolumn + 1, Classe.cAtribuicao, new Valor(yytext()));
        case ">=": return new Token(yyline + 1, yycolumn + 1, Classe.cMaiorIgual, new Valor(yytext()));
        case "<=": return new Token(yyline + 1, yycolumn + 1, Classe.cMenorIgual, new Valor(yytext()));
        case "<>": return new Token(yyline + 1, yycolumn + 1, Classe.cDiferente, new Valor(yytext()));
        case ":":  return new Token(yyline + 1, yycolumn + 1, Classe.cDoisPontos, new Valor(yytext()));
        case "+":  return new Token(yyline + 1, yycolumn + 1, Classe.cMais, new Valor(yytext()));
        case "-":  return new Token(yyline + 1, yycolumn + 1, Classe.cMenos, new Valor(yytext()));
        case "/":  return new Token(yyline + 1, yycolumn + 1, Classe.cDivisao, new Valor(yytext()));
        case "*":  return new Token(yyline + 1, yycolumn + 1, Classe.cMultiplicacao, new Valor(yytext()));
        case ">":  return new Token(yyline + 1, yycolumn + 1, Classe.cMaior, new Valor(yytext()));
        case "<":  return new Token(yyline + 1, yycolumn + 1, Classe.cMenor, new Valor(yytext()));
        case "=":  return new Token(yyline + 1, yycolumn + 1, Classe.cIgual, new Valor(yytext()));
        case ",":  return new Token(yyline + 1, yycolumn + 1, Classe.cVirgula, new Valor(yytext()));
        case ";":  return new Token(yyline + 1, yycolumn + 1, Classe.cPontoVirgula, new Valor(yytext()));
        case ".":  return new Token(yyline + 1, yycolumn + 1, Classe.cPonto, new Valor(yytext()));
        case "(": return new Token(yyline + 1, yycolumn + 1, Classe.cParEsq, new Valor(yytext()));
        case ")": return new Token(yyline + 1, yycolumn + 1, Classe.cParDir, new Valor(yytext()));
    }
}