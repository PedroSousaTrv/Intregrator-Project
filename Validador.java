import java.util.ArrayList;
import java.util.List;
import java.util.Locale;
import java.util.regex.Pattern;

/** Regras de validação dos dados de cadastro, separadas das telas para poderem ser testadas. */
public final class Validador {

    // usuario@dominio.edu.br, com subdomínios permitidos (corrige F-04)
    private static final Pattern EMAIL =
            Pattern.compile("^[a-z0-9._%+-]+@([a-z0-9-]+\\.)+edu\\.br$");

    private Validador() {
    }

    /** Remove espaços e padroniza em minúsculas (corrige F-05). */
    public static String normalizarEmail(String email) {
        return email == null ? "" : email.trim().toLowerCase(Locale.ROOT);
    }

    public static boolean emailValido(String emailNormalizado) {
        return EMAIL.matcher(emailNormalizado).matches();
    }

    public static String dominio(String emailNormalizado) {
        return emailNormalizado.substring(emailNormalizado.indexOf('@') + 1);
    }

    /** Nome com ao menos 3 caracteres e pelo menos uma letra (corrige F-06). */
    public static boolean nomeValido(String nome) {
        String n = nome == null ? "" : nome.trim();
        return n.length() >= 3 && n.matches(".*\\p{L}.*");
    }

    /** Retorna a lista de requisitos não atendidos; lista vazia = senha válida (corrige F-02 e F-03). */
    public static List<String> problemasSenha(String senha) {
        List<String> problemas = new ArrayList<>();
        if (senha.length() < 8) problemas.add("A senha deve possuir ao menos 8 caracteres");
        if (!senha.matches(".*\\d.*")) problemas.add("A senha deve possuir ao menos 1 numero");
        if (!senha.matches(".*[A-Z].*")) problemas.add("A senha deve possuir ao menos 1 letra maiuscula");
        if (!senha.matches(".*[a-z].*")) problemas.add("A senha deve possuir ao menos 1 letra minuscula");
        return problemas;
    }
}
