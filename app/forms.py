from wtforms.flask_wtf import FlaskForm
from wtforms import Form
# from wtforms import StringField, PasswordField, BooleanField, SubmitField
from wtforms.validators import DataRequired
from flask_wtf.file import FileField


class UploadForm(Form):
    file = FileField('', validators=[DataRequired()])
