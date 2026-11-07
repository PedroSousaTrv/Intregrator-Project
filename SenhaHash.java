import java.security.MessageDigest;
import java.security.NoSuchAlgorithmException;
import java.security.SecureRandom;
import java.security.spec.InvalidKeySpecException;
import java.util.Base64;
import javax.crypto.SecretKeyFactory;
import javax.crypto.spec.PBEKeySpec;

/**
 * Gera e confere o hash da senha (corrige F-18: senha nunca guardada em texto puro).
 * Usa PBKDF2 com SHA-256, que já vem no Java e não exige biblioteca externa.
 * Formato guardado: pbkdf2$iteracoes$salBase64$hashBase64
 */
public final class SenhaHash {

    private static final int ITERACOES = 600_000; // recomendação OWASP para PBKDF2-SHA256
    private static final int TAMANHO_SAL = 16;
    private static final int TAMANHO_HASH_BITS = 256;
    private static final SecureRandom RANDOM = new SecureRandom();

    private SenhaHash() {
    }

    public static String gerar(String senha) {
        byte[] sal = new byte[TAMANHO_SAL];
        RANDOM.nextBytes(sal);
        byte[] hash = pbkdf2(senha.toCharArray(), sal, ITERACOES);
        Base64.Encoder b64 = Base64.getEncoder();
        return "pbkdf2$" + ITERACOES + "$" + b64.encodeToString(sal) + "$" + b64.encodeToString(hash);
    }

    public static boolean confere(String senha, String guardado) {
        String[] partes = guardado.split("\\$");
        if (partes.length != 4 || !partes[0].equals("pbkdf2")) {
            return false;
        }
        int iteracoes = Integer.parseInt(partes[1]);
        byte[] sal = Base64.getDecoder().decode(partes[2]);
        byte[] esperado = Base64.getDecoder().decode(partes[3]);
        byte[] calculado = pbkdf2(senha.toCharArray(), sal, iteracoes);
        return MessageDigest.isEqual(esperado, calculado); // comparação em tempo constante
    }

    private static byte[] pbkdf2(char[] senha, byte[] sal, int iteracoes) {
        try {
            PBEKeySpec spec = new PBEKeySpec(senha, sal, iteracoes, TAMANHO_HASH_BITS);
            return SecretKeyFactory.getInstance("PBKDF2WithHmacSHA256").generateSecret(spec).getEncoded();
        } catch (NoSuchAlgorithmException | InvalidKeySpecException e) {
            throw new IllegalStateException("Falha ao gerar hash da senha", e);
        }
    }
}
