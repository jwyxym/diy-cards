--神醒的神魄
local s,id,o=GetID()
function s.initial_effect(c)
	aux.AddCodeList(c,16821470)
	aux.EnablePendulumAttribute(c)	
    c:EnableReviveLimit()
	--回到手卡
	local e0=Effect.CreateEffect(c)
    e0:SetDescription(aux.Stringid(id,0))
	e0:SetCategory(CATEGORY_TOHAND)
	e0:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
	e0:SetCode(EVENT_SPSUMMON_SUCCESS)
	e0:SetRange(LOCATION_PZONE)
	e0:SetCondition(s.bhcon)
	e0:SetTarget(s.bhtg)
	e0:SetOperation(s.bhop)
	c:RegisterEffect(e0)
	--仪式召唤	
    local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,1))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_TOGRAVE)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_PZONE)
	e1:SetCountLimit(1,id)
	e1:SetTarget(s.rsptg)
	e1:SetOperation(s.rspop)
	c:RegisterEffect(e1)
	--赋予效果    
    local e2=Effect.CreateEffect(c)
    e2:SetDescription(aux.Stringid(id,2))
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
	e2:SetCode(EVENT_SPSUMMON_SUCCESS)
	e2:SetOperation(s.efop)
	c:RegisterEffect(e2)
	--无效    
    local e3=Effect.CreateEffect(c)
    e3:SetDescription(aux.Stringid(id,3))
	e3:SetCategory(CATEGORY_NEGATE+CATEGORY_DESTROY)
	e3:SetType(EFFECT_TYPE_QUICK_O)
	e3:SetCode(EVENT_CHAINING)
	e3:SetProperty(EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_DAMAGE_CAL)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCountLimit(1,id+o)
	e3:SetCondition(s.discon)
    e3:SetCost(s.discost)
	e3:SetTarget(s.distg)
	e3:SetOperation(s.disop)
	c:RegisterEffect(e3)
	--回到手卡    
    local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
	e4:SetCode(EVENT_SPSUMMON_SUCCESS)
	e4:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e4:SetOperation(s.SpiritReturnReg)
	c:RegisterEffect(e4)        
end
function s.bhcon(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(Card.IsSummonType,1,nil,SUMMON_TYPE_PENDULUM)
end
function s.bhtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,e:GetHandler(),1,0,0)
    Duel.Hint(HINT_OPSELECTED,1-tp,e:GetDescription())
end
function s.bhop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c:IsRelateToEffect(e) then return end
	Duel.SendtoHand(c,nil,REASON_EFFECT)
end
function s.filter(c,e,tp)
	return c:IsSetCard(0xdf96) and (c:IsFaceup() or c:IsLocation(LOCATION_HAND+LOCATION_GRAVE))
end
function s.mfilter(c)
	return (c:GetLevel()>0 or c:GetRank()>0) and c:IsType(TYPE_MONSTER) and c:IsAbleToGrave()
end
function s.GetRitualLevel(c,rc)
	local lv=0
    if c:GetRank()>0 then 
    	lv=c:GetRank()
    else
    	lv=c:GetLevel()
    end
	return lv
end
function s.RitualCheckGreater(g,c,lv)
	Duel.SetSelectedCard(g)
	return g:CheckWithSumGreater(s.GetRitualLevel,lv,c)
end
function s.RitualCheckEqual(g,c,lv)
	return g:CheckWithSumEqual(s.GetRitualLevel,lv,#g,#g,c)
end
function s.RitualCheck(g,tp,c,lv,greater_or_equal)
	-- Check if there's space to summonp
	if c:IsLocation(LOCATION_EXTRA) then
		if Duel.GetLocationCountFromEx(tp,tp,g,c)<=0 then
			return false
		end
	else
		if Duel.GetMZoneCount(tp,g,tp)<=0 then
			return false
		end
	end
	return s["RitualCheck"..greater_or_equal](g,c,lv) and (not c.mat_group_check or c.mat_group_check(g,tp))
		and (not aux.RCheckAdditional or aux.RCheckAdditional(tp,g,c))
end
function s.RitualCheckAdditionalLevel(c,rc)
	local raw_level=c:GetRitualLevel(rc)
    if c:GetRank()>0 then raw_level=c:GetRank(rc) end
	local lv1=raw_level&0xffff
	local lv2=raw_level>>16
	if lv2>0 then
		return math.min(lv1,lv2)
	else
		return lv1
	end
end
function s.RitualCheckAdditional(c,lv,greater_or_equal)
	if greater_or_equal=="Equal" then
		return	function(g)
					return (not aux.RGCheckAdditional or aux.RGCheckAdditional(g)) and g:GetSum(s.RitualCheckAdditionalLevel,c)<=lv
				end
	else
		return	function(g,ec)
					if ec then
						return (not aux.RGCheckAdditional or aux.RGCheckAdditional(g,ec)) and g:GetSum(s.RitualCheckAdditionalLevel,c)-s.RitualCheckAdditionalLevel(ec,c)<=lv
					else
						return not aux.RGCheckAdditional or aux.RGCheckAdditional(g)
					end
				end
	end
end
function s.RitualUltimateFilter(c,filter,e,tp,m1,m2,level_function,greater_or_equal,chk)
	if bit.band(c:GetType(),0x81)~=0x81 or (filter and not filter(c,e,tp,chk)) or not c:IsCanBeSpecialSummoned(e,SUMMON_TYPE_RITUAL,tp,false,true) then return false end
	local mg=m1:Filter(Card.IsCanBeRitualMaterial,c,c)
	if m2 then
		mg:Merge(m2)
	end
	if c.mat_filter then
		mg=mg:Filter(c.mat_filter,c,tp)
	else
		mg:RemoveCard(c)
	end
	local lv=level_function(c)
	aux.GCheckAdditional=s.RitualCheckAdditional(c,lv,greater_or_equal)
	local res=mg:CheckSubGroup(s.RitualCheck,1,lv,tp,c,lv,greater_or_equal)
	aux.GCheckAdditional=nil
	return res
end
function s.rsptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		local mg1=Duel.GetRitualMaterialEx(tp)
        local mg2=Duel.GetMatchingGroup(s.mfilter,tp,LOCATION_EXTRA,0,nil)
		return Duel.IsExistingMatchingCard(s.RitualUltimateFilter,tp,LOCATION_HAND+LOCATION_EXTRA+LOCATION_GRAVE,0,1,nil,s.filter,e,tp,mg1,mg2,Card.GetLevel,"Equal")
	end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND+LOCATION_EXTRA+LOCATION_GRAVE)
    Duel.Hint(HINT_OPSELECTED,1-tp,e:GetDescription())
end
function s.rspop(e,tp,eg,ep,ev,re,r,rp)
	::cancel::
	local mg1=Duel.GetRitualMaterialEx(tp)
    local mg2=Duel.GetMatchingGroup(s.mfilter,tp,LOCATION_EXTRA,0,nil)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(s.RitualUltimateFilter),tp,LOCATION_HAND+LOCATION_EXTRA+LOCATION_GRAVE,0,1,1,nil,s.filter,e,tp,mg1,mg2,Card.GetLevel,"Equal")
	local tc=g:GetFirst()
	if tc then
		mg=mg1:Filter(Card.IsCanBeRitualMaterial,tc,tc)
        mg:Merge(mg2)
		if tc.mat_filter then
			mg=mg:Filter(tc.mat_filter,tc,tp)
		else
			mg:RemoveCard(tc)
		end
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RELEASE)
		aux.GCheckAdditional=s.RitualCheckAdditional(tc,tc:GetLevel(),"Equal")
		local mat=mg:SelectSubGroup(tp,s.RitualCheck,true,1,tc:GetLevel(),tp,tc,tc:GetLevel(),"Equal")
		aux.GCheckAdditional=nil
		if not mat then goto cancel end
		tc:SetMaterial(mat)
        local mat2=mat:Filter(Card.IsLocation,nil,LOCATION_EXTRA)
        if mat2:GetCount()>0 then
			Duel.HintSelection(mat2)
		end
		mat:Sub(mat2)
		Duel.ReleaseRitualMaterial(mat)
        Duel.SendtoGrave(mat2,REASON_EFFECT+REASON_MATERIAL+REASON_RITUAL)
		Duel.BreakEffect()
		Duel.SpecialSummon(tc,SUMMON_TYPE_RITUAL,tp,tp,false,true,POS_FACEUP)
		tc:CompleteProcedure()
	end
end
function s.efop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if Duel.GetFlagEffect(tp,id)~=0 or not c:IsSummonType(SUMMON_TYPE_RITUAL) then return end
    Duel.Hint(HINT_CARD,0,id)
	--不能除外    
    local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_CANNOT_REMOVE)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetTargetRange(1,1)
	e1:SetTarget(s.rmlimit)
    e1:SetReset(RESET_PHASE+PHASE_END)
	Duel.RegisterEffect(e1,tp)
	--不能回手    
    local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_CANNOT_TO_HAND)
	e2:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e2:SetTargetRange(1,1)
	e2:SetTarget(s.rmlimit)
    e2:SetReset(RESET_PHASE+PHASE_END)
	Duel.RegisterEffect(e2,tp)
	--不能回卡组    
    local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_FIELD)
	e3:SetCode(EFFECT_CANNOT_TO_DECK)
	e3:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e3:SetTargetRange(1,1)
	e3:SetTarget(s.rmlimit)
    e3:SetReset(RESET_PHASE+PHASE_END)
	Duel.RegisterEffect(e3,tp)
	Duel.RegisterFlagEffect(tp,id,RESET_PHASE+PHASE_END,0,1)
end
function s.rmlimit(e,c,tp,r,re)
	return (c:IsControler(tp) and c:IsType(TYPE_PENDULUM) and c:IsLocation(LOCATION_MZONE)) or (c:IsControler(1-tp) and c:IsOnField())
end
function s.discon(e,tp,eg,ep,ev,re,r,rp)
	return rp==1-tp and not e:GetHandler():IsStatus(STATUS_BATTLE_DESTROYED) and Duel.IsChainNegatable(ev)
end
function s.costfilter(c)
	return c:IsFaceup() and c:IsType(TYPE_SPIRIT) and c:IsAbleToDeck()
end
function s.discost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.costfilter,tp,LOCATION_EXTRA,0,1,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)
	local g=Duel.SelectMatchingCard(tp,s.costfilter,tp,LOCATION_EXTRA,0,1,1,nil)
	Duel.HintSelection(g)
	Duel.SendtoDeck(g,nil,2,REASON_COST)
end
function s.distg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	Duel.SetOperationInfo(0,CATEGORY_NEGATE,eg,1,0,0)
	if re:GetHandler():IsDestructable() and re:GetHandler():IsRelateToEffect(re) then
		Duel.SetOperationInfo(0,CATEGORY_DESTROY,eg,1,0,0)
	end
    Duel.Hint(HINT_OPSELECTED,1-tp,e:GetDescription())
end
function s.disop(e,tp,eg,ep,ev,re,r,rp)
	if Duel.NegateActivation(ev) and re:GetHandler():IsRelateToEffect(re)
		and Duel.Destroy(eg,REASON_EFFECT)~=0 then
        local c=e:GetHandler()        
        local lpz=Duel.GetFieldCard(tp,LOCATION_PZONE,0)
		local rpz=Duel.GetFieldCard(tp,LOCATION_PZONE,1)
        if lpz~=nil and rpz~=nil then        	
        	local loc=0
        	local ft1=Duel.GetLocationCount(tp,LOCATION_MZONE)
			local ft2=Duel.GetLocationCountFromEx(tp,tp,nil,TYPE_PENDULUM)
			local ft=Duel.GetUsableMZoneCount(tp)
        	local ect=c29724053 and Duel.IsPlayerAffectedByEffect(tp,29724053) and c29724053[tp]
			if ect and ect<ft2 then ft2=ect end
			if Duel.IsPlayerAffectedByEffect(tp,59822133) then
				if ft1>0 then ft1=1 end
				if ft2>0 then ft2=1 end
				ft=1
			end
			if ft1>0 then loc=loc|LOCATION_HAND end
			if ft2>0 then loc=loc|LOCATION_EXTRA end
            if loc~=0 then
            	local e1=Effect.CreateEffect(c)
				e1:SetType(EFFECT_TYPE_FIELD)
				e1:SetCode(EFFECT_EXTRA_PENDULUM_SUMMON)
				e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
				e1:SetTargetRange(1,0)
				e1:SetValue(s.pendvalue)
				e1:SetReset(RESET_PHASE+PHASE_END)
				Duel.RegisterEffect(e1,tp)
        		local eset={e1}           	
            	local lscale=lpz:GetLeftScale()
				local rscale=rpz:GetRightScale()
        		if lscale>rscale then lscale,rscale=rscale,lscale end
        		local tg=Duel.GetMatchingGroup(aux.PConditionFilter,tp,loc,0,nil,e,tp,lscale,rscale,eset)
				tg=tg:Filter(aux.PConditionExtraFilterSpecific,nil,e,tp,lscale,rscale,e1)
        		if tg:GetCount()>0 and Duel.SelectYesNo(tp,aux.Stringid(id,4)) then
                	Duel.BreakEffect()
					Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
					aux.GCheckAdditional=aux.PendOperationCheck(ft1,ft2,ft)
					local g=tg:SelectSubGroup(tp,aux.TRUE,false,1,1)
					aux.GCheckAdditional=nil
					if not g then
						e1:Reset()
						return
					end
					local sg=Group.CreateGroup()
					sg:Merge(g)
					Duel.HintSelection(Group.FromCards(lpz))
					Duel.HintSelection(Group.FromCards(rpz))
					Duel.RaiseEvent(sg,EVENT_SPSUMMON_SUCCESS_G_P,e,REASON_EFFECT,tp,tp,0)
					Duel.SpecialSummon(sg,SUMMON_TYPE_PENDULUM,tp,tp,true,true,POS_FACEUP)                	        
                end
                e1:Reset()
            end
        end		  
	end
end
function s.pendvalue(e,c)
	return c:IsSetCard(0xdf95)
end
function s.SpiritReturnReg(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
    if not c:IsSummonType(SUMMON_TYPE_RITUAL) then return end
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
	e1:SetDescription(1104)
	e1:SetCategory(CATEGORY_TOHAND)
	e1:SetCode(EVENT_PHASE+PHASE_END)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1)
	e1:SetReset(RESET_EVENT+0xd7e0000+RESET_PHASE+PHASE_END)
	e1:SetCondition(Auxiliary.SpiritReturnConditionForced)
	e1:SetTarget(Auxiliary.SpiritReturnTargetForced)
	e1:SetOperation(Auxiliary.SpiritReturnOperation)
	c:RegisterEffect(e1)
	local e2=e1:Clone()
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e2:SetCondition(Auxiliary.SpiritReturnConditionOptional)
	e2:SetTarget(Auxiliary.SpiritReturnTargetOptional)
	c:RegisterEffect(e2)
end