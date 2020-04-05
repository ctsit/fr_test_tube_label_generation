from reportlab.lib.pagesizes import letter
from reportlab.pdfgen import canvas
from reportlab.graphics.barcode import code39, code128, code93
from reportlab.graphics.barcode import eanbc, qr, usps
from reportlab.graphics.shapes import Drawing
from reportlab.lib.pagesizes import letter
from reportlab.lib.units import mm

from reportlab.graphics import renderPDF


barcode_value = "1234567890"
barcode128 = code128.Code128(barcode_value)

canvas = canvas.Canvas("formB.pdf", pagesize=letter)
c = canvas
canvas.setLineWidth(.3)
canvas.setFont('Helvetica', 9)


#canvas.drawString(30,750,'OFFICIAL COMMUNIQUE')
canvas.drawString(30,750,'KEVIN is Called K-DOG')

canvas.drawString(100,110,'KEVIN is Called K-DOG')
canvas.drawString(250,123,'KEVIN is Called K-DOG')
canvas.drawString(500,123,'KEVIN is Called K-DOG')

#
# canvas.drawString(30,735,'OF ACME INDUSTRIES')
# canvas.drawString(500,750,"12/12/2010")
# canvas.line(480,747,580,747)
#
# canvas.drawString(275,725,'AMOUNT OWED:')
# canvas.drawString(500,725,"$1,000.00")
# canvas.line(378,723,580,723)
#
# canvas.drawString(30,703,'RECEIVED BY:')
# canvas.line(120,700,580,700)
# canvas.drawString(120,703,"JOHN DOE")

barcode_value = "1234567890"

barcode39 = code39.Extended39(barcode_value)
barcode39Std = code39.Standard39(barcode_value, barHeight=10, stop=1)

# code93 also has an Extended and MultiWidth version
barcode93 = code93.Standard93(barcode_value)

barcode128 = code128.Code128(barcode_value)
# the multiwidth barcode appears to be broken
#barcode128Multi = code128.MultiWidthBarcode(barcode_value)

barcode_usps = usps.POSTNET("50158-9999")

codes = [barcode39Std]
#codes = [barcode39, barcode39Std, barcode93, barcode128]

#x = 1 * mm
#y = 285 * mm
#x1 = 6.4 * mm
################################################################################
x = 100 * mm
y = 100 * mm
x1 = 6.4 * mm

canvas.drawString(x,y+20,'KEVIN is Called K-DOG')
canvas.drawString(x,y+29,'Chris Barnes Physicist')

for code in codes:
    code.drawOn(c, x, y)
    y = y - 15 * mm
################################################################################

################################################################################
x = 50 * mm
y = 100 * mm
canvas.drawString(x,y+20,'KEVIN is Called K-DOG')
canvas.drawString(x,y+29,'Chris Barnes Physicist')

for code in codes:
    code.drawOn(c, x, y)
    y = y - 15 * mm
################################################################################

################################################################################
x = 1 * mm
y = 100 * mm
canvas.drawString(x,y+20,'KEVIN is Called K-DOG')
canvas.drawString(x,y+29,'Chris Barnes Physicist')
for code in codes:
    code.drawOn(c, x, y)
    y = y - 15 * mm
################################################################################
canvas.save()
