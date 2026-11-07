/** Estudante cadastrado. Guarda apenas o hash da senha, nunca a senha (corrige F-18). */
public class Estudante {
    private Integer idEstudante;
    private final int idInstituicao;
    private final String nomeCompleto;
    private final String emailInstitucional;
    private final String curso;
    private final int periodo;
    private final String senhaHash;

    public Estudante(Integer idEstudante, int idInstituicao, String nomeCompleto, String emailInstitucional,
                     String curso, int periodo, String senhaHash) {
        this.idEstudante = idEstudante;
        this.idInstituicao = idInstituicao;
        this.nomeCompleto = nomeCompleto;
        this.emailInstitucional = emailInstitucional;
        this.curso = curso;
        this.periodo = periodo;
        this.senhaHash = senhaHash;
    }

    public Integer getIdEstudante() { return idEstudante; }
    public void setIdEstudante(Integer idEstudante) { this.idEstudante = idEstudante; }
    public int getIdInstituicao() { return idInstituicao; }
    public String getNomeCompleto() { return nomeCompleto; }
    public String getEmailInstitucional() { return emailInstitucional; }
    public String getCurso() { return curso; }
    public int getPeriodo() { return periodo; }
    public String getSenhaHash() { return senhaHash; }
}
