--宇灾 垂怜蕨花
function c47700063.initial_effect(c)
	--search
	local e1=Effect.CreateEffect(c) 
	e1:SetCategory(CATEGORY_TOHAND)
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_TO_GRAVE)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetRange(LOCATION_MZONE) 
	e1:SetCondition(c47700063.thcon)
	e1:SetCost(c47700063.cost)
	e1:SetTarget(c47700063.thtg)
	e1:SetOperation(c47700063.thop)
	c:RegisterEffect(e1) 
	--special summon
	local e2=Effect.CreateEffect(c)
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_QUICK_O) 
	e2:SetCode(EVENT_FREE_CHAIN) 
	e2:SetRange(LOCATION_HAND+LOCATION_GRAVE)
	e2:SetCountLimit(1,47700063)  
	e2:SetCost(c47700063.spcost)
	e2:SetTarget(c47700063.sptg)
	e2:SetOperation(c47700063.spop)
	c:RegisterEffect(e2)
	Duel.AddCustomActivityCounter(47700063,ACTIVITY_SPSUMMON,c47700063.counterfilter)
end 
function c47700063.counterfilter(c)
	return not c:IsSummonLocation(LOCATION_EXTRA) or c:IsType(TYPE_FUSION)
end
function c47700063.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.GetCustomActivityCount(47700063,tp,ACTIVITY_SPSUMMON)==0 end
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET+EFFECT_FLAG_OATH)
	e1:SetTargetRange(1,0)
	e1:SetTarget(function(e,c,sump,sumtype,sumpos,targetp)
	return c:IsLocation(LOCATION_EXTRA) and not c:IsType(TYPE_FUSION) end)
	e1:SetReset(RESET_PHASE+PHASE_END)
	Duel.RegisterEffect(e1,tp)
end 
function c47700063.thcon(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(Card.IsAttribute,1,nil,ATTRIBUTE_DARK)
end 
function c47700063.thfilter(c)
	return c:IsType(TYPE_PENDULUM) and c:IsFaceup() and c:IsAbleToHand()
end
function c47700063.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(c47700063.thfilter,tp,LOCATION_GRAVE+LOCATION_REMOVED+LOCATION_EXTRA,0,1,nil) end
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_GRAVE+LOCATION_REMOVED+LOCATION_EXTRA)
end
function c47700063.psfilter(c)
	return c:IsType(TYPE_PENDULUM) and not c:IsForbidden()
end
function c47700063.filter1(c,e)
	return not c:IsImmuneToEffect(e)
end
function c47700063.filter2(c,e,tp,m,f,chkf)
	return c:IsType(TYPE_FUSION) and (not f or f(c))
		and c:IsCanBeSpecialSummoned(e,SUMMON_TYPE_FUSION,tp,false,false) and c:CheckFusionMaterial(m,nil,chkf)
end
function c47700063.thop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
	local g=Duel.SelectMatchingCard(tp,c47700063.thfilter,tp,LOCATION_GRAVE+LOCATION_REMOVED+LOCATION_EXTRA,0,1,1,nil)
	if g:GetCount()>0 then
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		Duel.ConfirmCards(1-tp,g) 
		local mg1=Duel.GetFusionMaterial(tp):Filter(c47700063.filter1,nil,e)
		local sg1=Duel.GetMatchingGroup(c47700063.filter2,tp,LOCATION_EXTRA,0,nil,e,tp,mg1,nil,chkf)
		local mg2=nil
		local sg2=nil
		local ce=Duel.GetChainMaterial(tp)
		if ce~=nil then
			local fgroup=ce:GetTarget()
			mg2=fgroup(ce,e,tp)
			local mf=ce:GetValue()
			sg2=Duel.GetMatchingGroup(c47700063.filter2,tp,LOCATION_EXTRA,0,nil,e,tp,mg2,mf,chkf)
		end
		local b1=Duel.GetFlagEffect(tp,17700063)==0 and (sg1:GetCount()>0 or (sg2~=nil and sg2:GetCount()>0)) 
		local b2=Duel.GetFlagEffect(tp,27700063)==0 and Duel.IsPlayerCanDraw(tp,1)
		if b1 or b2 then
			Duel.BreakEffect() 
			local xtable={aux.Stringid(47700063,0)} 
			if b1 then table.insert(xtable,aux.Stringid(47700063,1)) end 
			if b2 then table.insert(xtable,aux.Stringid(47700063,2)) end 
			local op=Duel.SelectOption(tp,table.unpack(xtable))+1 
			if xtable[op]==aux.Stringid(47700063,1) then  
				Duel.RegisterFlagEffect(tp,17700063,RESET_PHASE+PHASE_END,0,1)
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
				local e1=Effect.CreateEffect(c) 
				e1:SetType(EFFECT_TYPE_SINGLE) 
				e1:SetCode(EFFECT_CHANGE_ATTRIBUTE) 
				e1:SetRange(LOCATION_MZONE)  
				e1:SetValue(ATTRIBUTE_DARK)
				e1:SetReset(RESET_EVENT+RESETS_STANDARD) 
				tc:RegisterEffect(e1)
			end 
			if xtable[op]==aux.Stringid(47700063,2) then  
				Duel.RegisterFlagEffect(tp,27700063,RESET_PHASE+PHASE_END,0,2) 
				Duel.Draw(tp,1,REASON_EFFECT) 
			end 
		end 
	end
end
function c47700063.cfilter(c,ft,tp)
	return c:IsType(TYPE_FUSION) and (ft>0 or (c:IsControler(tp) and c:GetSequence()<5)) and (c:IsControler(tp) or c:IsFaceup())
end
function c47700063.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
	local ft=Duel.GetLocationCount(tp,LOCATION_MZONE)
	if chk==0 then return ft>-1 and Duel.CheckReleaseGroup(tp,c47700063.cfilter,1,nil,ft,tp) and c47700063.cost(e,tp,eg,ep,ev,re,r,rp,0) end
	c47700063.cost(e,tp,eg,ep,ev,re,r,rp,1)
	local g=Duel.SelectReleaseGroup(tp,c47700063.cfilter,1,1,nil,ft,tp)
	Duel.Release(g,REASON_COST)
end
function c47700063.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false) end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
function c47700063.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) then
		Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP) 
	end
end
