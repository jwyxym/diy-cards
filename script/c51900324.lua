--《生命·高塔》曼陀罗图书馆
local s,id,o=GetID()
function s.initial_effect(c)
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetCode(EVENT_TO_GRAVE)
	e1:SetCondition(s.spcon)
	e1:SetTarget(s.sptg)
	e1:SetOperation(s.spop)
	c:RegisterEffect(e1)
	local e2=e1:Clone()
	e2:SetCode(EVENT_REMOVE)
	c:RegisterEffect(e2)
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,1))
	e3:SetCategory(CATEGORY_REMOVE)
	e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
	e3:SetCode(EVENT_REMOVE)
	e3:SetCountLimit(1,id)
	e3:SetTarget(s.settg)
	e3:SetOperation(s.setop)
	c:RegisterEffect(e3)
end
function s.spcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return c:IsReason(REASON_EFFECT) and rp==1-tp and c:IsPreviousControler(tp)
end
function s.filter2(c,e,tp)
	return c:IsFaceupEx() and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	local g=Duel.GetMatchingGroup(Card.IsType,tp,0,LOCATION_GRAVE+LOCATION_REMOVED,nil)
	local tg=g:GetMaxGroup(Card.GetAttack):Filter(s.filter2,nil,e,tp)
	local g2=Duel.GetMatchingGroup(Card.IsFaceup,tp,0,LOCATION_MZONE,nil)
	local tg2=g2:GetMaxGroup(Card.GetAttack):Filter(Card.IsControlerCanBeChanged,nil)
	local b1=Duel.IsPlayerCanDraw(tp,1) and Duel.IsExistingTarget(s.filter1,tp,LOCATION_GRAVE,0,3,nil)
	local b2=tg:GetCount()>0
	if chk==0 then return b1 or b2 end
	local op=0
	if b1 and b2 then
		op=Duel.SelectOption(1-tp,aux.Stringid(id,2),aux.Stringid(id,3))
	elseif b1 then
		op=Duel.SelectOption(1-tp,aux.Stringid(id,2))
	else
		op=Duel.SelectOption(1-tp,aux.Stringid(id,3))+1
	end
	e:SetLabel(op)
	if op==0 then
	else
		e:SetCategory(CATEGORY_SPECIAL_SUMMON)
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
		local g=Duel.GetMatchingGroup(s.filter2,tp,0,LOCATION_GRAVE+LOCATION_REMOVED,nil,e,tp)
		Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g,1,0,0)
	end
end
function s.spfilter(c,e,tp)
	return c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP,1-tp)
end
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	if e:GetLabel()==0 then
		local g2=Duel.GetMatchingGroup(Card.IsFaceup,tp,0,LOCATION_MZONE,nil)
		local tg2=g2:GetMaxGroup(Card.GetAttack):Filter(Card.IsControlerCanBeChanged,nil)
		if tg2:GetCount()>0 then
			local tc=tg2:Select(1-tp,1,1,nil)
			Duel.GetControl(tc,tp)
		end
	else
		local g=Duel.GetMatchingGroup(Card.IsType,tp,0,LOCATION_GRAVE+LOCATION_REMOVED,nil)
		local tg=g:GetMaxGroup(Card.GetAttack):Filter(s.filter2,nil)
		Duel.Hint(HINT_SELECTMSG,1-tp,HINTMSG_SPSUMMON)
		local sg=tg:Select(1-tp,1,1,nil)
		if sg:GetCount()>0 then
			Duel.SpecialSummon(sg,0,tp,tp,false,false,POS_FACEUP)
		end
	end
end
function s.settg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return true end
	Duel.SetOperationInfo(0,CATEGORY_LEAVE_GRAVE,c,1,0,0)
end
function s.setop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) then Duel.SSet(tp,c) end
end