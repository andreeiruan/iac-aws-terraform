data "aws_iam_policy_document" "consumer" {
  statement {
    effect    = "Allow"
    resources = [aws_sqs_queue.queue.arn, aws_sqs_queue.queue_deadletter[0].arn]

    actions = [
      "sqs:GetQueueAttributes",
      "sqs:GetQueueUrl",
      "sqs:ReceiveMessage",
      "sqs:DeleteMessage*",
      "sqs:PurgeQueue",
      "sqs:ChangeMessageVisibility*"
    ]
  }
}

data "aws_iam_policy_document" "pusher" {
  statement {
    effect    = "Allow"
    resources = [aws_sqs_queue.queue.arn, aws_sqs_queue.queue_deadletter[0].arn]

    actions = [
      "sqs:GetQueueAttributes",
      "sqs:GetQueueUrl",
      "sqs:SendMessage*"
    ]
  }
}

resource "aws_iam_policy" "consumer" {
  name   = "sqs-${var.queue_name}-consumer"
  policy = data.aws_iam_policy_document.consumer.json
}

resource "aws_iam_policy" "pusher" {
  name   = "sqs-${var.queue_name}-pusher"
  policy = data.aws_iam_policy_document.pusher.json
}