resource "aws_sns_topic" "sns_topic"{
  name="${var.environment}-${var.region}-${var.sns_topic_name}"
  #tfsec:ignore:aws-sns-topic-encryption-use-cmk
  #checkov:skip=CKV_AWS_136: "Ensure that SNS topics are encrypted using KMS"
  kms_master_key_id ="alias/aws/sns"
  display_name="${var.environment}-${var.region}-${var.sns_topic_name}"  
}