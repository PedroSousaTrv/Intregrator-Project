import java.util.Scanner;

/**
 * Centraliza a leitura do teclado em um único Scanner (corrige F-11).
 * Nenhuma outra classe deve criar Scanner(System.in).
 */
public class Entrada {

    /** Lançada quando a entrada termina (ex.: fim do arquivo ou Ctrl+D). */
    public static class FimDaEntrada extends RuntimeException {
        private static final long serialVersionUID = 1L;

        public FimDaEntrada() {
            super("Entrada encerrada");
        }
    }

    private final Scanner sc;

    public Entrada(Scanner sc) {
        this.sc = sc;
    }

    public String lerTexto(String pergunta) {
        System.out.println(pergunta);
        if (!sc.hasNextLine()) {
            throw new FimDaEntrada();
        }
        return sc.nextLine();
    }

    /** Lê um número inteiro entre min e max, repetindo até ser válido (corrige F-07). */
    public int lerInteiro(String pergunta, int min, int max) {
        while (true) {
            String texto = lerTexto(pergunta).trim();
            try {
                int valor = Integer.parseInt(texto);
                if (valor >= min && valor <= max) {
                    return valor;
                }
            } catch (NumberFormatException e) {
                // valor não numérico: cai na mensagem abaixo
            }
            System.out.println("Valor invalido. Digite um numero de " + min + " a " + max + ".");
        }
    }
}
