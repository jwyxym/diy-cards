--诱血姬 吸血鬼
function c11771400.initial_effect(c)
    -- 特殊召唤
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(11771400,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_HAND+LOCATION_GRAVE)
	e1:SetCountLimit(1,11771400)
	e1:SetCost(c11771400.cost1)
	e1:SetTarget(c11771400.tg1)
	e1:SetOperation(c11771400.op1)
	c:RegisterEffect(e1)
	-- 超量素材
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(11771400,4))
	e2:SetCategory(CATEGORY_TOGRAVE+CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetProperty(EFFECT_FLAG_DELAY)
	e2:SetCode(EVENT_TO_GRAVE)
	e2:SetCondition(c11771400.con2)
	e2:SetTarget(c11771400.tg2)
	e2:SetOperation(c11771400.op2)
	c:RegisterEffect(e2)
	-- 特殊召唤
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
	e3:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e3:SetCode(EVENT_BATTLE_DESTROYING)
	e3:SetOperation(c11771400.op3)
	c:RegisterEffect(e3)
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(11771400,2))
	e4:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e4:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e4:SetCode(EVENT_PHASE+PHASE_BATTLE)
	e4:SetRange(LOCATION_MZONE)
	e4:SetCountLimit(1)
	e4:SetCondition(c11771400.con4)
	e4:SetTarget(c11771400.tg4)
	e4:SetOperation(c11771400.op4)
	c:RegisterEffect(e4)
	-- 自肃相关
	Duel.AddCustomActivityCounter(11771400,ACTIVITY_SUMMON,c11771400.counterfilter)
	Duel.AddCustomActivityCounter(11771400,ACTIVITY_SPSUMMON,c11771400.counterfilter)
end
-- 自肃
function c11771400.counterfilter(c)
	return c:IsRace(RACE_ZOMBIE)
end
-- 1
function c11771400.filter1(c)
	return c:IsFaceup() and c:IsRace(RACE_ZOMBIE) and c:IsType(TYPE_XYZ)
end
function c11771400.cost1(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		local g=Duel.GetMatchingGroup(c11771400.filter1,tp,LOCATION_MZONE,LOCATION_MZONE,nil)
		return g:IsExists(Card.CheckRemoveOverlayCard,1,nil,tp,1,REASON_COST)
	end
	local g=Duel.GetMatchingGroup(c11771400.filter1,tp,LOCATION_MZONE,LOCATION_MZONE,nil)
	local sg=g:FilterSelect(tp,Card.CheckRemoveOverlayCard,1,1,nil,tp,1,REASON_COST)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVEXYZ)
	local tc=sg:GetFirst()
	tc:RemoveOverlayCard(tp,1,1,REASON_COST)
end
function c11771400.tg1(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false) end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
function c11771400.op1(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) and Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)~=0 then
		local op=Duel.SelectOption(tp,aux.Stringid(11771400,1),aux.Stringid(11771400,2),aux.Stringid(11771400,3))
		local sel=0
		if op==0 then
			sel=1
		elseif op==1 then
			sel=-1
		else
			sel=0
		end
		if sel~=0 then
			local e1=Effect.CreateEffect(c)
			e1:SetType(EFFECT_TYPE_SINGLE)
			e1:SetCode(EFFECT_UPDATE_LEVEL)
			e1:SetValue(sel)
			e1:SetReset(RESET_EVENT+RESETS_STANDARD)
			c:RegisterEffect(e1)
		end
	end
end
-- 2
function c11771400.con2(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return c:IsReason(REASON_COST) and re:IsActivated() and re:GetHandler():IsRace(RACE_ZOMBIE) and re:IsActiveType(TYPE_XYZ)
		and c:IsPreviousLocation(LOCATION_OVERLAY)
end
function c11771400.filter2(c)
	return c:IsRace(RACE_ZOMBIE) and c:IsAbleToGrave()
end
function c11771400.tg2(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(c11771400.filter2,tp,LOCATION_DECK,0,1,nil) end
	Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,nil,1,tp,LOCATION_DECK)
end
function c11771400.op2(e,tp,eg,ep,ev,re,r,rp)
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)
    local g=Duel.SelectMatchingCard(tp,c11771400.filter2,tp,LOCATION_DECK,0,1,1,nil)
    local tc=g:GetFirst()
    if tc and Duel.SendtoGrave(tc,REASON_EFFECT)>0 and tc:IsLocation(LOCATION_GRAVE) and tc:IsSetCard(0x8e) then
        local b1=Duel.IsExistingMatchingCard(Card.IsRace,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil,RACE_ZOMBIE)
                and Duel.GetLocationCount(tp,LOCATION_MZONE)>0
        if b1 then
            local sel=aux.SelectFromOptions(tp,
                {b1,aux.Stringid(11771400,4)},
                {true,aux.Stringid(11771400,5)})
            if sel==1 then
                Duel.BreakEffect()
                Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)
                local sg=Duel.SelectMatchingCard(tp,Card.IsRace,tp,LOCATION_MZONE,LOCATION_MZONE,1,1,nil,RACE_ZOMBIE)
                if sg:GetCount()>0 and Duel.SendtoGrave(sg,REASON_EFFECT)~=0 and sg:GetFirst():IsLocation(LOCATION_GRAVE) then
                    Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)
                end
            end
        end
    end
end
-- 3
function c11771400.op3(e,tp,eg,ep,ev,re,r,rp)
	e:GetHandler():RegisterFlagEffect(11771401,RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_BATTLE,0,1)
end
function c11771400.con4(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():GetFlagEffect(11771401)~=0
end
function c11771400.filter4(c,e,tp,rc,tid)
	return c:IsReason(REASON_BATTLE) and c:GetReasonCard()==rc and c:GetTurnID()==tid
		and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
function c11771400.tg4(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and Duel.IsExistingMatchingCard(c11771400.filter4,tp,LOCATION_GRAVE,LOCATION_GRAVE,1,nil,e,tp,e:GetHandler(),Duel.GetTurnCount()) end
	local g=Duel.GetMatchingGroup(c11771400.filter4,tp,LOCATION_GRAVE,LOCATION_GRAVE,nil,e,tp,e:GetHandler(),Duel.GetTurnCount())
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g,1,0,0)
end
function c11771400.op4(e,tp,eg,ep,ev,re,r,rp)
	local ft=Duel.GetLocationCount(tp,LOCATION_MZONE)
	if ft<=0 then return end
	if Duel.IsPlayerAffectedByEffect(tp,59822133) then ft=1 end
	local tg=Duel.GetMatchingGroup(aux.NecroValleyFilter(c11771400.filter4),tp,LOCATION_GRAVE,LOCATION_GRAVE,nil,e,tp,e:GetHandler(),Duel.GetTurnCount())
	local g=nil
	if tg:GetCount()>ft then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
		g=tg:Select(tp,ft,ft,nil)
	else
		g=tg
	end
	if g:GetCount()>0 then
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
	end
end
