--唱晓新月之女
local s,id,o=GetID()
function s.initial_effect(c)
	--连接召唤：鸟兽族·魔法师族怪兽2只
	aux.AddLinkProcedure(c,s.lmatfilter,2,2)
	c:EnableReviveLimit()
	--①：特殊召唤的场合，从卡组·墓地把1张「唱晓」灵摆怪兽表侧加入额外卡组
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_TOEXTRA+CATEGORY_TOHAND)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetCountLimit(1,id)
	e1:SetTarget(s.tetg)
	e1:SetOperation(s.teop)
	c:RegisterEffect(e1)
	--②：这张卡的连接区有「唱晓」怪兽的场合，双方回合可以发动
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetCategory(CATEGORY_ATKCHANGE)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetCode(EVENT_FREE_CHAIN)
	e2:SetRange(LOCATION_MZONE)
	e2:SetHintTiming(0,TIMINGS_CHECK_MONSTER+TIMING_END_PHASE)
	e2:SetCountLimit(1,id+10000)
	e2:SetCondition(s.atkcon)
	e2:SetOperation(s.atkop)
	c:RegisterEffect(e2)
end
--通用
function s.lmatfilter(c)
	return c:IsRace(RACE_WINGEDBEAST) or c:IsRace(RACE_SPELLCASTER)
end
function s.pfilter(c)
	return c:IsSetCard(0xe99) and c:IsType(TYPE_PENDULUM) and c:IsType(TYPE_MONSTER)
end
function s.cxfilter(c,tp)
	return c:IsSetCard(0xe99) and c:IsType(TYPE_MONSTER) and c:IsControler(tp) and c:IsFaceup()
end
function s.matfilter(c,tp)
	return c:IsSetCard(0xe99) and c:IsType(TYPE_MONSTER) and c:IsControler(tp)
end
--①
function s.tetg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.pfilter,tp,LOCATION_DECK+LOCATION_GRAVE,0,1,nil) end
	Duel.SetOperationInfo(0,CATEGORY_TOEXTRA,nil,1,tp,LOCATION_DECK+LOCATION_GRAVE)
end
function s.teop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOEXTRA)
	local g=Duel.SelectMatchingCard(tp,s.pfilter,tp,LOCATION_DECK+LOCATION_GRAVE,0,1,1,nil)
	if g:GetCount()>0 then
		Duel.SendtoExtraP(g,nil,REASON_EFFECT)
	end
	--以「唱晓」怪兽作为连接素材连接召唤的场合，可以再从卡组加1只「唱晓」怪兽
	if not c:IsSummonType(SUMMON_TYPE_LINK) then return end
	local mg=c:GetMaterial()
	if mg==nil or not mg:IsExists(s.matfilter,1,nil,tp) then return end
	if not Duel.IsExistingMatchingCard(s.cxfilter,tp,LOCATION_DECK,0,1,nil,tp) then return end
	if not Duel.SelectYesNo(tp,aux.Stringid(id,2)) then return end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
	local sg=Duel.SelectMatchingCard(tp,s.cxfilter,tp,LOCATION_DECK,0,1,1,nil,tp)
	if sg:GetCount()>0 then
		Duel.SendtoHand(sg,nil,REASON_EFFECT)
		Duel.ConfirmCards(1-tp,sg)
	end
end
--②
function s.atkcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return c:GetLinkedGroup():IsExists(s.cxfilter,1,nil,tp)
end
function s.atkop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c:IsRelateToEffect(e) then return end
	local g=c:GetLinkedGroup()
	if g:GetCount()==0 then return end
	local atk=0
	local tc=g:GetFirst()
	while tc do
		atk=atk+tc:GetAttack()
		tc=g:GetNext()
	end
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_UPDATE_ATTACK)
	e1:SetValue(atk)
	e1:SetReset(RESET_EVENT+RESETS_STANDARD)
	c:RegisterEffect(e1)
	local tc=g:GetFirst()
	while tc do
		local e2=Effect.CreateEffect(c)
		e2:SetType(EFFECT_TYPE_SINGLE)
		e2:SetCode(EFFECT_CHANGE_RACE)
		e2:SetValue(RACE_SPELLCASTER)
		e2:SetReset(RESET_EVENT+RESETS_STANDARD)
		tc:RegisterEffect(e2)
		tc=g:GetNext()
	end
end
