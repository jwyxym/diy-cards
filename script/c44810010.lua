--次元盗具 次元列车
local s,id=GetID()
function s.initial_effect(c)
	-- ①：发动时的效果处理（宣言种类，确认对方卡组顶，匹配则除外并检索）
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_REMOVE+CATEGORY_TOHAND+CATEGORY_DECKDES)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetOperation(s.operation1)
	c:RegisterEffect(e1)
	-- ②：永续效果，次元魔盗攻击力上升
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_UPDATE_ATTACK)
	e2:SetRange(LOCATION_FZONE)
	e2:SetTargetRange(LOCATION_MZONE,0)
	e2:SetTarget(s.atktg)
	e2:SetValue(s.atkval)
	c:RegisterEffect(e2)
	-- ③：这张卡被除外的场合，以自己场上1只次元魔盗为对象，从卡组装备1张次元盗具
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,1))
	e3:SetCategory(CATEGORY_EQUIP)
	e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e3:SetProperty(EFFECT_FLAG_DELAY+EFFECT_FLAG_CARD_TARGET)
	e3:SetCode(EVENT_REMOVE)
	e3:SetCountLimit(1,id+id)
	e3:SetTarget(s.target3)
	e3:SetOperation(s.operation3)
	c:RegisterEffect(e3)
end
-- ① target
function s.thfilter(c)
	return c:IsCode(44810011) and c:IsAbleToHand()
end
-- ① operation
function s.operation1(e,tp,eg,ep,ev,re,r,rp)
	if Duel.GetFieldGroupCount(1-tp,LOCATION_DECK,0)>0
	and Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_DECK,0,1,nil) and Duel.GetFlagEffect(tp,id)==0 and Duel.SelectYesNo(tp,aux.Stringid(id,0)) then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_CARDTYPE)
		local opt=Duel.AnnounceType(tp)
		local g=Duel.GetDecktopGroup(1-tp,1)
		local tc=g:GetFirst()
		if #g==0 then return end
		Duel.ConfirmDecktop(1-tp,1)
		if (opt==0 and tc:IsType(TYPE_MONSTER)) or (opt==1 and tc:IsType(TYPE_SPELL)) or (opt==2 and tc:IsType(TYPE_TRAP)) then
			Duel.Remove(tc,POS_FACEUP,REASON_EFFECT)
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
			local sg=Duel.SelectMatchingCard(tp,s.thfilter,tp,LOCATION_DECK,0,1,1,nil)
			if #sg>0 then
				Duel.SendtoHand(sg,nil,REASON_EFFECT)
				Duel.ConfirmCards(1-tp,sg)
			end
		end
		Duel.RegisterFlagEffect(tp,id,RESET_PHASE+PHASE_END,nil,1)
	end
end
-- ② 攻击力上升的目标筛选（只对次元魔盗怪兽）
function s.atktg(e,c)
	return c:IsSetCard(0x5ce1) and c:IsFaceup()
end
-- ② 攻击力上升的值
function s.atkval(e,c)
	local tp=e:GetHandlerPlayer()
	local ct=Duel.GetMatchingGroupCount(s.atkfilter,tp,LOCATION_SZONE,0,nil)
	return ct*100
end
function s.atkfilter(c)
	return c:IsSetCard(0x3ce1) and c:IsFaceup()
end
-- ③ target
function s.target3(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsControler(tp) and chkc:IsLocation(LOCATION_MZONE) and chkc:IsFaceup() and chkc:IsSetCard(0x5ce1) end
	if chk==0 then
		return Duel.IsExistingTarget(s.eqfilter,tp,LOCATION_MZONE,0,1,nil)
			and Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_DECK,0,1,nil)
	end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)
	local g=Duel.SelectTarget(tp,s.eqfilter,tp,LOCATION_MZONE,0,1,1,nil)
	Duel.SetOperationInfo(0,CATEGORY_EQUIP,nil,1,tp,LOCATION_DECK)
end
function s.eqfilter(c)
	return c:IsFaceup() and c:IsSetCard(0x5ce1)
end
-- ③ operation
function s.operation3(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetFirstTarget()
	if not tc or not tc:IsRelateToEffect(e) or tc:IsFacedown() then return end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_EQUIP)
	local g=Duel.SelectMatchingCard(tp,Card.IsSetCard,tp,LOCATION_DECK,0,1,1,nil,0x3ce1)
	if #g==0 then return end
	local eqc=g:GetFirst()
	Duel.Equip(tp,eqc,tc)
end