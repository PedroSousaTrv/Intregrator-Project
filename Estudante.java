
public class Estudante {
        private String nomeCompleto;
        private String emailInstitucional;
        private String curso;
        private int periodo;
        private String senha;

        public Estudante(String nomeCompleto, String emailInstitucional, String curso, int periodo, String senha) {
            this.nomeCompleto = nomeCompleto;
            this.emailInstitucional = emailInstitucional;
            this.curso = curso;
            this.periodo = periodo;
            this.senha = senha;
        }

        public String getEmailInstitucional() {
            return emailInstitucional;
        }

        public String getNomeCompleto() {
            return nomeCompleto;
        }

        public String getSenha(){
            return senha;
        }
}

