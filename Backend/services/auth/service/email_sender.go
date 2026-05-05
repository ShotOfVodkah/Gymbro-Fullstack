package service

import (
    "fmt"

    "github.com/resend/resend-go/v3"
)

type EmailSender interface {
    SendVerificationEmail(to string, verificationURL string) error
}

type ResendEmailSender struct {
    client *resend.Client
    from   string
}

func NewResendEmailSender(apiKey string, from string) *ResendEmailSender {
    return &ResendEmailSender{
        client: resend.NewClient(apiKey),
        from:   from,
    }
}

func (s *ResendEmailSender) SendVerificationEmail(to string, verificationURL string) error {
    html := fmt.Sprintf(`
        <div style="font-family: Arial, sans-serif; line-height: 1.5;">
            <h2>Welcome to GymBro</h2>
            <p>Please confirm your email to activate your account.</p>
            <p>
                <a href="%s"
                   style="display:inline-block;padding:12px 18px;background:#7c3aed;color:#ffffff;text-decoration:none;border-radius:12px;">
                    Confirm email
                </a>
            </p>
            <p>If you did not create this account, you can ignore this email.</p>
        </div>
    `, verificationURL)

    params := &resend.SendEmailRequest{
        From:    s.from,
        To:      []string{to},
        Subject: "Confirm your GymBro email",
        Html:    html,
    }

    _, err := s.client.Emails.Send(params)
    return err
}