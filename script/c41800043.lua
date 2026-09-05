--珠泪哀歌族·丽斑人鱼
local s,id=GetID()

function s.initial_effect(c)
	-- 效果1: 手卡·墓地特殊召唤并送墓
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_TOGRAVE)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_HAND+LOCATION_GRAVE)
	e1:SetCountLimit(1,id)
	e1:SetCondition(s.spcon)
	e1:SetTarget(s.sptg)
	e1:SetOperation(s.spop)
	c:RegisterEffect(e1)
	-- 效果2: 被效果送去墓地时的效果
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,3))
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_TO_GRAVE)
	e2:SetProperty(EFFECT_FLAG_DELAY)
	e2:SetCondition(s.thcon1)
	e2:SetTarget(s.target)
	c:RegisterEffect(e2)
end

-- 效果1: 发动条件
function s.spcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsLocation(LOCATION_HAND) or e:GetHandler():IsLocation(LOCATION_GRAVE)
end

-- 效果1: 特殊召唤目标
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then
		local g=Duel.GetFieldGroup(tp,LOCATION_HAND,0)
	if g:IsContains(c) then
		g:RemoveCard(c)
	end
		return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
			and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
			and g:CheckSubGroup(s.gselect,2,2)
	end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,c,1,0,0)
	Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,nil,2,tp,LOCATION_HAND)
	Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,nil,3,tp,LOCATION_DECK)
end

-- 效果1: 手卡特召操作
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) and Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)>0 then
		local g=Duel.GetFieldGroup(tp,LOCATION_HAND,0)
		if #g>=2 and g:CheckSubGroup(s.gselect,2,2) then
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DISCARD)
			local g1=g:SelectSubGroup(tp,s.gselect,false,2,2)
			if g1 and g1:GetCount()==2 and Duel.SendtoGrave(g1,REASON_DISCARD+REASON_EFFECT)~=0 then
				Duel.BreakEffect()
			-- 从卡组上面把3张卡送去墓地
			Duel.DiscardDeck(tp,3,REASON_EFFECT)
			end
		end
	end
end
function s.gselect(g)
	return g:IsExists(Card.IsSetCard,1,nil,0x181) and g:FilterCount(Card.IsAbleToGrave,nil)==2
end
-- 效果2: 被效果送去墓地的条件
function s.thcon1(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsReason(REASON_EFFECT)
end

-- 效果2: 检索目标
function s.thfilter1(c)
	return c:IsSetCard(0x181) and c:IsType(TYPE_SPELL) and c:IsAbleToHand()
end
function s.thfilter2(c)
	return c:IsSetCard(0x181) and c:IsType(TYPE_SPELL) and c:IsFaceupEx() and c:IsAbleToHand()
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	local l=Duel.GetFlagEffectLabel(tp,id)
	local b1=(not l or l&1==0) and Duel.IsExistingMatchingCard(s.thfilter1,tp,LOCATION_DECK,0,1,nil)
	local b2=(not l or l&2==0) and Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and Duel.IsExistingTarget(s.thfilter2,tp,LOCATION_REMOVED,0,1,nil)
	if chk==0 then return b1 or b2 end
	local op=0
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_EFFECT)
	if b1 and b2 then
		op=Duel.SelectOption(tp,aux.Stringid(id,1),aux.Stringid(id,2))
	elseif b1 then
		op=Duel.SelectOption(tp,aux.Stringid(id,1))
	else
		op=Duel.SelectOption(tp,aux.Stringid(id,2))+1
	end
	if op==0 then
		e:SetCategory(CATEGORY_SEARCH+CATEGORY_TOHAND)
		e:SetOperation(s.thop1)
		if l then Duel.SetFlagEffectLabel(tp,id,l|1)
		else Duel.RegisterFlagEffect(tp,id,RESET_PHASE+PHASE_END,0,1,1) end
		Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
	else
		e:SetCategory(CATEGORY_TOHAND)
		e:SetOperation(s.thop2)
		if l then Duel.SetFlagEffectLabel(tp,id,l|2)
		else Duel.RegisterFlagEffect(tp,id,RESET_PHASE+PHASE_END,0,1,2) end
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
		local g=Duel.SelectTarget(tp,s.thfilter2,tp,LOCATION_REMOVED,0,1,1,nil)
		Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_REMOVED)
	end
end
function s.thop1(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
	local g=Duel.SelectMatchingCard(tp,s.thfilter1,tp,LOCATION_DECK,0,1,1,nil)
	Duel.SendtoHand(g,nil,REASON_EFFECT)
	Duel.ConfirmCards(1-tp,g)
end
function s.thop2(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		Duel.SendtoHand(tc,nil,REASON_EFFECT)
	end
end
