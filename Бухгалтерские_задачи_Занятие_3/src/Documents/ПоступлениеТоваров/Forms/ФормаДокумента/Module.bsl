
////////////////////////////////////////////////////////////////////////////////
// РЕДАКТИРОВАНИЕ СТРОКИ ТЧ

&НаКлиенте
Процедура ТоварыНоменклатураПриИзменении(Элемент)
	
	ВычислитьСуммуВТекущейСтрокеТЧ();
	
	ТекДанные = Элементы.Товары.ТекущиеДанные;
	
	ТекДанные.СчетУчета = СерверныйСВызовом.ПолучитьСчетУчетаНоменклатуры(ТекДанные.Номенклатура, Объект.Организация);
	
КонецПроцедуры

&НаКлиенте
Процедура ТоварыКоличествоПриИзменении(Элемент)
	
	ВычислитьСуммуВТекущейСтрокеТЧ();
	
КонецПроцедуры

&НаКлиенте
Процедура ТоварыЦенаПриИзменении(Элемент)
	
	ВычислитьСуммуВТекущейСтрокеТЧ();
	
КонецПроцедуры

&НаКлиенте
Процедура ВычислитьСуммуВТекущейСтрокеТЧ()
	
	ТекДанные = Элементы.Товары.ТекущиеДанные;
	ТекДанные.Сумма = ТекДанные.Цена * ТекДанные.Количество;
	
КонецПроцедуры
