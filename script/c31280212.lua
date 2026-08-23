--奇幻魔兽·摩拉
local s,id,o=GetID()
function s.initial_effect(c)
	aux.AddCodeList(c,31280213)
	--确认
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_TOGRAVE+CATEGORY_DRAW)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_HAND)
	e1:SetCountLimit(1,id)
	e1:SetTarget(s.eftg)
	e1:SetOperation(s.efop)
	c:RegisterEffect(e1)
	--加入手卡
	local e2=Effect.CreateEffect(c)
    e2:SetDescription(aux.Stringid(id,1))
	e2:SetCategory(CATEGORY_TOHAND)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_PHASE+PHASE_END)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetCountLimit(1,id+o*10000)
	e2:SetCondition(s.thcon)
	e2:SetTarget(s.thtg)
	e2:SetOperation(s.thop)
	c:RegisterEffect(e2)
	if not s.global_check then
		s.global_check=true
		local ge1=Effect.CreateEffect(c)
		ge1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		ge1:SetCode(EVENT_TO_GRAVE)
		ge1:SetOperation(s.checkop)
		Duel.RegisterEffect(ge1,0)
	end
end
function s.checkfilter(c,tp)
	return not c:IsCode(id) and c:IsRace(RACE_SPELLCASTER) and c:IsControler(tp)
end
function s.checkop(e,tp,eg,ep,ev,re,r,rp)
	if eg:IsExists(s.checkfilter,1,nil,0) then Duel.RegisterFlagEffect(0,id,RESET_PHASE+PHASE_END,0,1) end
	if eg:IsExists(s.checkfilter,1,nil,1) then Duel.RegisterFlagEffect(1,id,RESET_PHASE+PHASE_END,0,1) end
end
function s.tdfilter(c)
	return c:IsRace(RACE_SPELLCASTER) and c:IsAttribute(ATTRIBUTE_LIGHT) and c:IsLevel(5)
end
function s.eftg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
    local b1=c:IsCanBeSpecialSummoned(e,0,tp,false,false) 
    	and Duel.GetLocationCount(tp,LOCATION_MZONE)>0
    local b2=c:IsAbleToGrave() and Duel.IsExistingMatchingCard(s.tdfilter,tp,LOCATION_DECK,0,1,nil)
	if chk==0 then return Duel.GetFieldGroupCount(tp,LOCATION_DECK,0)>0 
    	and (b1 or b2) and Duel.IsPlayerCanDraw(tp,1) end
	Duel.SetTargetPlayer(tp)
	Duel.SetTargetParam(1)
	Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,1)
end
function s.efop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if Duel.GetFieldGroupCount(tp,LOCATION_DECK,0)<=0 then return end
	Duel.ConfirmDecktop(tp,1)
	local tc=Duel.GetDecktopGroup(tp,1):GetFirst()
    if not c:IsRelateToEffect(e) then return end
    local res=false
	if tc:IsCode(31280213) then
    	if c:IsCanBeSpecialSummoned(e,0,tp,false,false) 
        	and Duel.GetLocationCount(tp,LOCATION_MZONE)>0 then
            res=Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)
        end
    else
    	if c:IsAbleToGrave() and Duel.SendtoGrave(c,REASON_EFFECT)~=0 
        	and c:IsLocation(LOCATION_GRAVE) then
            Duel.Hint(HINT_SELECTMSG,tp,aux.Stringid(id,2))
			local dc=Duel.SelectMatchingCard(tp,s.tdfilter,tp,LOCATION_DECK,0,1,1,nil):GetFirst()
			if dc then
				Duel.ShuffleDeck(tp)
				Duel.MoveSequence(dc,SEQ_DECKTOP)
				Duel.ConfirmDecktop(tp,1)
                res=true
			end            
        end    
    end
    if res then
    	Duel.BreakEffect()
        local p,d=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER,CHAININFO_TARGET_PARAM) 
        Duel.Draw(p,d,REASON_EFFECT)
    end
end
function s.thcon(e,tp,eg,ep,ev,re,r,rp)
	return Duel.GetFlagEffect(tp,id)>0
end
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsAbleToHand() end
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,e:GetHandler(),1,0,0)
end
function s.thop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) then
		Duel.SendtoHand(c,nil,REASON_EFFECT)
	end
end