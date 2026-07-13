--暗黑剑 拉格纳洛克
function c21362836.initial_effect(c)
	aux.AddCodeList(c,21362800)
	aux.AddEquipSpellEffect(c,true,true,Card.IsFaceup,nil)
	--atk up
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_EQUIP)
	e1:SetCode(EFFECT_UPDATE_ATTACK) 
	e1:SetValue(-4000)
	c:RegisterEffect(e1) 
	--destroy replace
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_CONTINUOUS+EFFECT_TYPE_EQUIP)
	e2:SetCode(EFFECT_DESTROY_REPLACE)
	e2:SetTarget(c21362836.desreptg)
	e2:SetOperation(c21362836.desrepop)
	c:RegisterEffect(e2) 
	--eff 
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_IGNITION)  
	e2:SetRange(LOCATION_SZONE) 
	e2:SetCountLimit(1)
	e2:SetCondition(function(e) 
	return e:GetHandler():GetEquipTarget()~=nil end)
	e2:SetTarget(c21362836.efftg)
	e2:SetOperation(c21362836.effop)
	c:RegisterEffect(e2)
end
function c21362836.desreptg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	local tg=c:GetEquipTarget()
	if chk==0 then return tg and tg:IsReason(REASON_BATTLE+REASON_EFFECT) and not tg:IsReason(REASON_REPLACE) and e:GetHandler():IsAbleToHand() end
	return Duel.SelectEffectYesNo(tp,c,96)
end
function c21362836.desrepop(e,tp,eg,ep,ev,re,r,rp)
	Duel.SendtoHand(e:GetHandler(),nil,REASON_EFFECT+REASON_REPLACE)  
	Duel.BreakEffect()
	local tc=c:GetEquipTarget()
	Duel.Remove(tc,POS_FACEUP,REASON_EFFECT+REASON_REPLACE)
end
function c21362836.efffil(c) 
	return c:IsFaceup() and c:IsType(TYPE_EFFECT)   
end 
function c21362836.efftg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsControler(tp) and chkc:IsLocation(LOCATION_MZONE) and c21362836.efffil(chkc) end 
	if chk==0 then return Duel.IsExistingTarget(c21362836.efffil,tp,LOCATION_MZONE,0,1,nil) end 
	local g=Duel.SelectTarget(tp,c21362836.efffil,tp,LOCATION_MZONE,0,1,1,nil) 
end
function c21362836.effop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local tc=Duel.GetFirstTarget() 
	if tc then 
		local e3=Effect.CreateEffect(tc)
		e3:SetDescription(aux.Stringid(21362836,0))
		e3:SetCategory(CATEGORY_SPECIAL_SUMMON)
		e3:SetType(EFFECT_TYPE_QUICK_O) 
		e3:SetCode(EVENT_FREE_CHAIN)
		e3:SetProperty(EFFECT_FLAG_CLIENT_HINT)
		e3:SetRange(LOCATION_MZONE) 
		e3:SetCost(c21362836.fuscost)
		e3:SetTarget(c21362836.fustg)
		e3:SetOperation(c21362836.fusop)
		e3:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END+RESET_OPPO_TURN)
		tc:RegisterEffect(e3)
	end 
end 
function c21362836.ctfil(c) 
	return c:IsAbleToGraveAsCost() and c:IsCode(21362836) and c:IsFaceup()  
end 
function c21362836.fuscost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(c21362836.ctfil,tp,LOCATION_ONFIELD,0,1,nil) end 
	local g=Duel.SelectMatchingCard(tp,c21362836.ctfil,tp,LOCATION_ONFIELD,0,1,1,nil) 
	Duel.SendtoGrave(g,REASON_COST) 
end 
function c21362836.fusfilter1(c,e)
	return c:IsType(TYPE_MONSTER) and c:IsAbleToRemove() and c:IsCanBeFusionMaterial() and not c:IsImmuneToEffect(e)
end
function c21362836.fusfilter2(c,e)
	return not c:IsImmuneToEffect(e)
end
function c21362836.fusspfilter(c,e,tp,m,f,gc,chkf)
	return (not f or f(c))
		and c:IsCanBeSpecialSummoned(e,SUMMON_TYPE_FUSION,tp,false,false) and c:CheckFusionMaterial(m,gc,chkf)
end
function c21362836.fuschkfilter(c,tp)
	return c:IsControler(tp) and c:IsCode(21362800)
end
function c21362836.fusexfilter(c,tp)
	return c:IsControler(1-tp)  
end
function c21362836.fusfcheck(tp,sg,fc)
	if sg:IsExists(c21362836.fuschkfilter,1,nil,tp) then
		return true 
	else
		return not sg:IsExists(c21362836.fusexfilter,1,nil,tp)
	end
end
function c21362836.fustg(e,tp,eg,ep,ev,re,r,rp,chk) 
	local c=e:GetHandler()
	if chk==0 then
		local chkf=tp
		local mg1=Duel.GetFusionMaterial(tp):Filter(c21362836.fusfilter2,nil,e)
		local mg2=Duel.GetMatchingGroup(c21362836.fusfilter1,tp,0,LOCATION_MZONE,nil,e)
		if mg1:IsExists(c21362836.fuschkfilter,1,nil,tp) and mg2:GetCount()>0 or mg2:IsExists(c21362836.fuschkfilter,1,nil,tp) then
			mg1:Merge(mg2)
		end
		aux.FCheckAdditional=c21362836.fusfcheck
		local res=Duel.IsExistingMatchingCard(c21362836.fusspfilter,tp,LOCATION_EXTRA,0,1,nil,e,tp,mg1,nil,c,chkf)
		if not res then
			local ce=Duel.GetChainMaterial(tp)
			if ce~=nil then
				local fgroup=ce:GetTarget()
				local mg3=fgroup(ce,e,tp)
				local mf=ce:GetValue()
				res=Duel.IsExistingMatchingCard(c21362836.fusspfilter,tp,LOCATION_EXTRA,0,1,nil,e,tp,mg3,mf,c,chkf)
			end
		end
		aux.FCheckAdditional=nil
		return res
	end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_EXTRA) 
end
function c21362836.fusop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local chkf=tp
	local mg1=Duel.GetFusionMaterial(tp):Filter(c21362836.fusfilter2,nil,e)
	local mg2=Duel.GetMatchingGroup(c21362836.fusfilter1,tp,0,LOCATION_MZONE,nil,e)
	if mg1:IsExists(c21362836.fuschkfilter,1,nil,tp) and mg2:GetCount()>0 or mg2:IsExists(c21362836.fuschkfilter,1,nil,tp) then
		mg1:Merge(mg2)
	end
	aux.FCheckAdditional=c21362836.fusfcheck
	local sg1=Duel.GetMatchingGroup(c21362836.fusspfilter,tp,LOCATION_EXTRA,0,nil,e,tp,mg1,nil,c,chkf)
	local mg3=nil
	local sg2=nil
	local ce=Duel.GetChainMaterial(tp)
	if ce~=nil then
		local fgroup=ce:GetTarget()
		mg3=fgroup(ce,e,tp)
		local mf=ce:GetValue()
		sg2=Duel.GetMatchingGroup(c21362836.fusspfilter,tp,LOCATION_EXTRA,0,nil,e,tp,mg3,mf,c,chkf)
	end
	if sg1:GetCount()>0 or (sg2~=nil and sg2:GetCount()>0) then
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
			local mat2=Duel.SelectFusionMaterial(tp,tc,mg3,nil,chkf)
			local fop=ce:GetOperation()
			fop(ce,e,tp,tc,mat2)
		end
		tc:CompleteProcedure()
	end
	aux.FCheckAdditional=nil
end





