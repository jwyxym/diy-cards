-- 侦探助手
local s,id=GetID()

local s,id=GetID()

function s.initial_effect(c)
	--①检索效果（这个卡名的1回合1次）
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_SUMMON_SUCCESS)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetCountLimit(1, id+100)  -- 独立计数器
	e1:SetTarget(s.thtg)
	e1:SetOperation(s.thop)
	c:RegisterEffect(e1)
	
	local e2=e1:Clone()
	e2:SetCode(EVENT_SPSUMMON_SUCCESS)
	c:RegisterEffect(e2)
	
	--②离场特召效果（这个卡名的1回合1次）
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,1))
	e3:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e3:SetCode(EVENT_LEAVE_FIELD)
	e3:SetProperty(EFFECT_FLAG_DELAY+EFFECT_FLAG_DAMAGE_STEP)
	e3:SetCountLimit(1, id+200)  -- 独立计数器
	e3:SetCondition(s.spcon)
	e3:SetTarget(s.sptg)
	e3:SetOperation(s.spop)
	c:RegisterEffect(e3)
end

--①检索
function s.thfilter(c)
	return c:IsAbleToHand() and (c:IsSetCard(0x1D5C) or c:IsCode(58577036))
end

function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_DECK,0,1,nil) end
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end

function s.thop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
	local g=Duel.SelectMatchingCard(tp,s.thfilter,tp,LOCATION_DECK,0,1,1,nil)
	if #g>0 then
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		Duel.ConfirmCards(1-tp,g)
	end
end

--②离场条件
function s.spcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsPreviousLocation(LOCATION_ONFIELD)
end

function s.spfilter_detective(c,e,tp)
	return c:IsSetCard(0x1D5C) and c:IsLevelAbove(7) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end

function s.spfilter_spellcaster(c,e,tp)
	return c:IsRace(RACE_SPELLCASTER) and c:IsLevelAbove(7) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end

function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	local has_fusion=false
	local mg=Duel.GetFieldGroup(tp,LOCATION_MZONE,0)
	for tc in aux.Next(mg) do
		if tc:IsSetCard(0x1D5C) and tc:IsType(TYPE_FUSION) then
			has_fusion=true
			break
		end
	end
	
	local can_detective=Duel.IsExistingMatchingCard(s.spfilter_detective,tp,LOCATION_HAND+LOCATION_GRAVE,0,1,nil,e,tp)
	local can_spellcaster=false
	if has_fusion then
		can_spellcaster=Duel.IsExistingMatchingCard(s.spfilter_spellcaster,tp,LOCATION_HAND+LOCATION_GRAVE,0,1,nil,e,tp)
	end
	
	if chk==0 then return can_detective or can_spellcaster end
	
	local op=0
	if can_detective and can_spellcaster then
		op=Duel.SelectOption(tp,aux.Stringid(id,2),aux.Stringid(id,3))
	elseif can_detective then
		op=0
	else
		op=1
	end
	e:SetLabel(op)
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND+LOCATION_GRAVE)
end

function s.spop(e,tp,eg,ep,ev,re,r,rp)
	local op=e:GetLabel()
	local g=nil
	
	if op==0 then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
		g=Duel.SelectMatchingCard(tp,s.spfilter_detective,tp,LOCATION_HAND+LOCATION_GRAVE,0,1,1,nil,e,tp)
	else
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
		g=Duel.SelectMatchingCard(tp,s.spfilter_spellcaster,tp,LOCATION_HAND+LOCATION_GRAVE,0,1,1,nil,e,tp)
	end
	
	if g and #g>0 then
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
	end
end
