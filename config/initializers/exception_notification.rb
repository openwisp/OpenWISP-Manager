if Rails.env.production?
  recipients = 'root@localhost'
  sender = 'root@localhost'
  email_subject_prefix = '[OWM] '

  ExceptionNotification::Notifier.exception_recipients = recipients
  ExceptionNotification::Notifier.sender_address = sender
  ExceptionNotification::Notifier.email_prefix = email_subject_prefix
  ExceptionNotification::Notifier.sections = %w(request session authlogic environment backtrace)
end