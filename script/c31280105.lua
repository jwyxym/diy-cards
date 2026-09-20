--露娜的玩偶
local s,id,o=GetID()
function s.initial_effect(c)
	aux.AddCodeList(c,31280102)
	--卡组检索    
    local e1=Effect.CreateEffect(c)
    e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH+CATEGORY_SPECIAL_SUMMON+CATEGORY_FUSION_SUMMON)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,id)
	e1:SetTarget(s.thtg)
	e1:SetOperation(s.thop)
	c:RegisterEffect(e1)
	--抽卡
    local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetCategory(CATEGORY_DRAW+CATEGORY_RECOVER)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetProperty(EFFECT_FLAG_DELAY)
	e2:SetCode(EVENT_TO_GRAVE)
	e2:SetCountLimit(1,id+o*10000)
	e2:SetCondition(s.drcon)
	e2:SetTarget(s.drtg)
	e2:SetOperation(s.drop)
	c:RegisterEffect(e2)    
end
function s.thfilter(c)
	return aux.IsCodeListed(c,31280102) and c:IsType(TYPE_MONSTER) and c:IsAbleToHand()
end
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_DECK+LOCATION_GRAVE,0,1,nil) end
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK+LOCATION_GRAVE)
end
function s.filter1(c,e)
	return not c:IsImmuneToEffect(e)
end
function s.filter2(c,e,tp,m,f,chkf)
	return c:IsType(TYPE_FUSION) and (not f or f(c)) and c:IsRace(RACE_ZOMBIE) and c:IsLevelBelow(5)
		and c:IsCanBeSpecialSummoned(e,SUMMON_TYPE_FUSION,tp,false,false) and c:CheckFusionMaterial(m,nil,chkf)
end
function s.thop(e,tp,eg,ep,ev,re,r,rp)
	local g=Duel.GetMatchingGroup(aux.NecroValleyFilter(s.thfilter),tp,LOCATION_DECK+LOCATION_GRAVE,0,nil)
	if g:GetCount()>0 then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
		local hc=g:Select(tp,1,1,nil):GetFirst()
		if Duel.SendtoHand(hc,nil,REASON_EFFECT)~=0 and hc:IsLocation(LOCATION_HAND) then
			Duel.ConfirmCards(1-tp,hc)
            local chkf=tp
			local mg1=Duel.GetFusionMaterial(tp):Filter(s.filter1,nil,e)
			local sg1=Duel.GetMatchingGroup(s.filter2,tp,LOCATION_EXTRA,0,nil,e,tp,mg1,nil,chkf)
			local mg2=nil
			local sg2=nil
			local ce=Duel.GetChainMaterial(tp)
			if ce~=nil then
				local fgroup=ce:GetTarget()
				mg2=fgroup(ce,e,tp)
				local mf=ce:GetValue()
				sg2=Duel.GetMatchingGroup(s.filter2,tp,LOCATION_EXTRA,0,nil,e,tp,mg2,mf,chkf)
			end
			if (sg1:GetCount()>0 or (sg2~=nil and sg2:GetCount()>0)) and Duel.SelectYesNo(tp,aux.Stringid(id,2)) then
                Duel.ShuffleHand(tp)
                Duel.BreakEffect()
				local sg=sg1:Clone()
				if sg2 then sg:Merge(sg2) end
				Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
				local tg=sg:Select(tp,1,1,nil)
				local tc=tg:GetFirst()
				if sg1:IsContains(tc) and (sg2==nil or not sg2:IsContains(tc) or not Duel.SelectYesNo(tp,ce:GetDescription())) then
					local mat1=Duel.SelectFusionMaterial(tp,tc,mg1,nil,chkf)
					tc:SetMaterial(mat1)
					Duel.SendtoGrave(mat1,REASON_EFFECT+REASON_MATERIAL+REASON_FUSION)
					Duel.BreakEffect()
					Duel.SpecialSummon(tc,SUMMON_TYPE_FUSION,tp,tp,false,false,POS_FACEUP)
				else
					local mat2=Duel.SelectFusionMaterial(tp,tc,mg2,nil,chkf)
					local fop=ce:GetOperation()
					fop(ce,e,tp,tc,mat2)
				end
				tc:CompleteProcedure()
			end
        end
	end
end
function s.drcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsReason(REASON_EFFECT)
end
function s.bhfilter(c)
	return aux.IsCodeListed(c,31280102) and c:IsType(TYPE_TRAP) and c:IsAbleToHand()
end
function s.drtg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
    if c:IsPreviousLocation(LOCATION_ONFIELD) and c:IsPreviousPosition(POS_FACEUP) then
    	e:SetLabel(100)
    else
    	e:SetLabel(0)
    end
    local b1=Duel.IsPlayerCanDraw(tp,1)
    local b2=e:GetLabel()==100 and Duel.IsExistingMatchingCard(s.bhfilter,tp,LOCATION_DECK,0,1,nil)
	if chk==0 then return (b1 or b2) end
    if e:GetLabel()==100 then
    	e:SetCategory(CATEGORY_DRAW+CATEGORY_RECOVER+CATEGORY_TOHAND+CATEGORY_SEARCH)
        e:SetProperty(EFFECT_FLAG_DELAY)        
    else
    	e:SetCategory(CATEGORY_DRAW+CATEGORY_RECOVER)
        e:SetProperty(EFFECT_FLAG_PLAYER_TARGET+EFFECT_FLAG_DELAY)
    end
	Duel.SetOperationInfo(0,CATEGORY_RECOVER,nil,0,tp,400)
    Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,1)
end
function s.drop(e,tp,eg,ep,ev,re,r,rp)
	if Duel.Recover(tp,400,REASON_EFFECT)~=0 then
    	if e:GetLabel()==100 and Duel.IsExistingMatchingCard(s.bhfilter,tp,LOCATION_DECK,0,1,nil)
        	and (not Duel.IsPlayerCanDraw(tp,1) or Duel.SelectYesNo(tp,aux.Stringid(id,3))) then
    		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
			local g=Duel.SelectMatchingCard(tp,s.bhfilter,tp,LOCATION_DECK,0,1,1,nil)
			if g:GetCount()>0 then
				Duel.SendtoHand(g,nil,REASON_EFFECT)
				Duel.ConfirmCards(1-tp,g)
			end
        else
        	Duel.Draw(tp,1,REASON_EFFECT)
        end
    end
end