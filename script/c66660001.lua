--幻星集 魔术师
local m=66660001
local cm=_G["c"..m]
Duel.LoadScript("c666Tarrow.lua")
function cm.initial_effect(c)
	local str="拥有着变化莫测的能力和心想事成的本领。\n幻星集的魔术师啊，请降临于此，展现新的可能性！"
	XiaoyeServerPublicFunctionLibrary.SummonLines(c,str)
	aux.EnablePendulumAttribute(c)
	xiaoye.PendulumScale(c)
	xiaoye.CannotBeMaterial(c)
	xiaoye.CardTargetBeTuner(c)
	xiaoye.SpecialSummonWithoutPendulum(c)
	xiaoye.PWhenDestory(c)
--spsummon
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(m,1))
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetRange(LOCATION_MZONE)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetCountLimit(1)
	e2:SetTarget(cm.tg)
	e2:SetOperation(cm.op)
	c:RegisterEffect(e2)
--set
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(m,0))
	e3:SetType(EFFECT_TYPE_QUICK_O)
	e3:SetCode(EVENT_CHAINING)
	e3:SetProperty(EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_DAMAGE_CAL)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCountLimit(1)
	e3:SetCondition(cm.con1)
	e3:SetTarget(cm.tg1)
	e3:SetOperation(cm.op1)
	c:RegisterEffect(e3)
--p
	local e4=Effect.CreateEffect(c)
	e4:SetCategory(CATEGORY_DESTROY+CATEGORY_SPECIAL_SUMMON)
	e4:SetType(EFFECT_TYPE_IGNITION)
	e4:SetRange(LOCATION_PZONE)
	e4:SetCountLimit(1,m+1)
	e4:SetCost(xiaoye.PendulumEffectCost)
	e4:SetTarget(cm.tg2)
	e4:SetOperation(cm.op2)
	c:RegisterEffect(e4)
end
function cm.filter(c,e,tp)
	return c:IsFaceup() and c:GetOriginalType()&TYPE_MONSTER~=0
		and c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP,1-tp)
end
function cm.tg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_SZONE) and chkc:IsControler(1-tp) and cm.filter(chkc,e,tp) end
	if chk==0 then return Duel.IsExistingTarget(cm.filter,tp,0,LOCATION_SZONE,1,nil,e,tp) and Duel.GetLocationCount(1-tp,LOCATION_MZONE)>0 end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	local g=Duel.SelectTarget(tp,cm.filter,tp,0,LOCATION_SZONE,1,1,nil,e,tp)
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g,1,0,0)
end
function cm.op(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) and Duel.GetLocationCount(1-tp,LOCATION_MZONE)>0 then
		Duel.SpecialSummon(tc,0,tp,1-tp,false,false,POS_FACEUP)
	end
end
function cm.con1(e,tp,eg,ep,ev,re,r,rp)
	return ep==1-tp and re:IsActiveType(TYPE_MONSTER) and not e:GetHandler():IsStatus(STATUS_BATTLE_DESTROYED)
end
function cm.cfilter1(c,att)
	return c:IsSetCard(0x666) and c:IsType(TYPE_PENDULUM) and not c:IsForbidden() and c:IsAttribute(att)
end
function cm.filter1(c)
	return c:GetSequence()==0 or c:GetSequence()==4
end
function cm.tg1(e,tp,eg,ep,ev,re,r,rp,chk)
	local att=re:GetHandler():GetAttribute()
	local g=Duel.GetMatchingGroupCount(cm.cfilter1,tp,0,LOCATION_SZONE,nil)
	if chk==0 then return Duel.IsExistingMatchingCard(cm.filter1,tp,LOCATION_DECK,0,1,nil,att) and g<2 end
end
function cm.op1(e,tp,eg,ep,ev,re,r,rp)
	local att=re:GetHandler():GetAttribute()
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOFIELD)
		local g=Duel.SelectMatchingCard(tp,cm.filter1,tp,LOCATION_DECK,0,1,1,nil,att)
		local tc=g:GetFirst()
		if tc then
			Duel.MoveToField(tc,tp,1-tp,LOCATION_PZONE,POS_FACEUP,true)
		end
end
function cm.tg2(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.GetFieldGroupCount(tp,LOCATION_DECK,0)>2 end
end
function cm.filter2(c,e,tp)
	return c:IsSetCard(0x666) and c:IsCanBeSpecialSummoned(e,0,tp,fasle,fasle)
end
function cm.op2(e,tp,eg,ep,ev,re,r,rp)
	if Duel.GetFieldGroupCount(tp,LOCATION_DECK,0)<=2 then return end
	local g=Duel.GetDecktopGroup(tp,3)
	local ct=g:GetCount()
	if ct>0 and e:GetHandler():IsRelateToEffect(e) and Duel.Destroy(e:GetHandler(),REASON_EFFECT)~=0 then
		Duel.BreakEffect()
		if Duel.GetLocationCount(tp,LOCATION_MZONE)>0 then
			Duel.ConfirmDecktop(tp,3)
			if g:FilterCount(cm.filter2,nil,e,tp)>=1 then
				Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
				local sg=g:FilterSelect(tp,cm.filter2,1,1,nil,e,tp)
				local tc=sg:GetFirst()
				if tc then
					Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)
				end
			end
		end
		Duel.ShuffleDeck(tp)
	end
end