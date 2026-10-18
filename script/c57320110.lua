--真红与群青·塞达&贝阿朵丽丝
local s,id,o=GetID()
function s.initial_effect(c)
	--同调召唤
	c:EnableReviveLimit()
    local e0=Effect.CreateEffect(c)
	e0:SetDescription(1164)
	e0:SetType(EFFECT_TYPE_FIELD)
	e0:SetCode(EFFECT_SPSUMMON_PROC)
	e0:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e0:SetRange(LOCATION_EXTRA)
	e0:SetCondition(s.SynMixCondition(s.matfilter,nil,nil,aux.NonTuner(nil),1,99,nil))
	e0:SetTarget(s.SynMixTarget(s.matfilter,nil,nil,aux.NonTuner(nil),1,99,nil))
	e0:SetOperation(Auxiliary.SynMixOperation(s.matfilter,nil,nil,aux.NonTuner(nil),1,99,nil))
	e0:SetValue(SUMMON_TYPE_SYNCHRO)
	c:RegisterEffect(e0)
	--衍生物
	local e1=Effect.CreateEffect(c)
    e1:SetDescription(aux.Stringid(id,0))
    e1:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_TOKEN)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetProperty(EFFECT_FLAG_DELAY)
    e1:SetCountLimit(1,id)
	e1:SetCondition(s.tkcon)
    e1:SetCost(s.tkcost)
	e1:SetTarget(s.tktg)
	e1:SetOperation(s.tkop)
	c:RegisterEffect(e1)
	--特殊召唤	
    local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetCode(EVENT_FREE_CHAIN)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetHintTiming(0,TIMING_END_PHASE)
	e2:SetCountLimit(1,id+o)
	e2:SetCondition(s.spcon)
    e2:SetCost(aux.bfgcost)
	e2:SetTarget(s.sptg)
	e2:SetOperation(s.spop)
	c:RegisterEffect(e2)
end
function s.matfilter(c,syncard)
	return c:IsTuner(syncard) and c:IsRace(RACE_WARRIOR)
end
function s.tkcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsSummonType(SUMMON_TYPE_SYNCHRO)
end
function s.costfilter(c)
	return c:IsRace(RACE_WARRIOR) and c:IsAbleToRemoveAsCost()
end
function s.tkcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.costfilter,tp,LOCATION_GRAVE,0,1,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)
	local g=Duel.SelectMatchingCard(tp,s.costfilter,tp,LOCATION_GRAVE,0,1,1,nil)
	Duel.Remove(g,POS_FACEUP,REASON_COST)
end
function s.tktg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and Duel.IsPlayerCanSpecialSummonMonster(tp,57320120,0,TYPES_TOKEN_MONSTER+TYPE_TUNER,1500,1500,1,RACE_WARRIOR,ATTRIBUTE_DARK) end
	Duel.SetOperationInfo(0,CATEGORY_TOKEN,nil,1,0,0)
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,0,0)
end
function s.lvfilter(c,rc)
	return c:GetSynchroLevel(rc)>0
end
function s.tkop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if Duel.IsPlayerCanSpecialSummonMonster(tp,57320120,0,TYPES_TOKEN_MONSTER+TYPE_TUNER,1500,1500,1,RACE_WARRIOR,ATTRIBUTE_DARK) 
    	and Duel.GetLocationCount(tp,LOCATION_MZONE)>0 then        
		local token=Duel.CreateToken(tp,57320120)        
        local mg=c:GetMaterial():Filter(s.lvfilter,nil,c)        
		if Duel.SpecialSummonStep(token,0,tp,tp,false,false,POS_FACEUP) then
        	local lv=mg:GetSum(Card.GetSynchroLevel,c)
        	local e1=Effect.CreateEffect(c)
			e1:SetType(EFFECT_TYPE_SINGLE)
			e1:SetCode(EFFECT_CHANGE_LEVEL)
			e1:SetValue(lv)
			e1:SetReset(RESET_EVENT+RESETS_STANDARD)
			token:RegisterEffect(e1)
		end
        Duel.SpecialSummonComplete()
    end
    local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e1:SetTargetRange(1,0)
	e1:SetTarget(s.splimit)
	e1:SetReset(RESET_PHASE+PHASE_END)
	Duel.RegisterEffect(e1,tp)
end
function s.splimit(e,c)
	return not c:IsRace(RACE_WARRIOR)
end
function s.spcon(e,tp,eg,ep,ev,re,r,rp)
	return Duel.GetTurnPlayer()==1-tp
end
function s.filter(c,e,tp,m,f,chkf)
	return c:IsType(TYPE_FUSION) and (not f or f(c))
		and c:IsCanBeSpecialSummoned(e,SUMMON_TYPE_FUSION,tp,false,false) and c:CheckFusionMaterial(m,nil,chkf)
end
function s.check(tp,g,fc)
	return g:IsExists(Card.IsRace,1,nil,RACE_WARRIOR)
end
function s.mfilter(c)
	return c:IsRace(RACE_WARRIOR) and c:IsType(TYPE_MONSTER) and c:IsFaceupEx()
end
function s.syncheck(g,tp,syncard)
	return g:IsExists(s.mfilter,1,nil) and aux.SynMixHandCheck(g,tp,syncard) and syncard:IsSynchroSummonable(nil,g,#g-1,#g-1)
end
function s.scfilter(c,tp,mg)
	if not c:IsType(TYPE_SYNCHRO) then return false end
	aux.GCheckAdditional=aux.SynGroupCheckLevelAddition(c)
	local res=mg:CheckSubGroup(s.syncheck,2,#mg,tp,c)
	aux.GCheckAdditional=nil
	return res
end
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	local chkf=tp
	local mg1=Duel.GetFusionMaterial(tp):Filter(Card.IsOnField,nil)
	aux.FCheckAdditional=s.check
	local res=Duel.IsExistingMatchingCard(s.filter,tp,LOCATION_EXTRA,0,1,nil,e,tp,mg1,nil,chkf)
	if not res then
		local ce=Duel.GetChainMaterial(tp)
		if ce~=nil then
			local fgroup=ce:GetTarget()
			local mg2=fgroup(ce,e,tp)
			local mf=ce:GetValue()
			res=Duel.IsExistingMatchingCard(s.filter,tp,LOCATION_EXTRA,0,1,nil,e,tp,mg2,mf,chkf)
		end
	end
	aux.FCheckAdditional=nil
    local smg=Duel.GetSynchroMaterial(tp)
	if smg:IsExists(Card.GetHandSynchro,1,nil) then
		local smg2=Duel.GetMatchingGroup(nil,tp,LOCATION_HAND,0,nil)
		if smg2:GetCount()>0 then
        	smg:Merge(smg2)
        end
	end
	local b1=res
	local b2=Duel.IsPlayerCanSpecialSummon(tp)
    	and Duel.IsExistingMatchingCard(s.scfilter,tp,LOCATION_EXTRA,0,1,nil,tp,smg)
	if chk==0 then return (b1 or b2) end	
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_EXTRA)    
end
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	local chkf=tp
	local mg1=Duel.GetFusionMaterial(tp):Filter(Card.IsOnField,nil):Filter(aux.NOT(Card.IsImmuneToEffect),nil,e)
	aux.FCheckAdditional=s.check
	local sg1=Duel.GetMatchingGroup(s.filter,tp,LOCATION_EXTRA,0,nil,e,tp,mg1,nil,chkf)
	local mg2,sg2=nil,nil
	local ce=Duel.GetChainMaterial(tp)
	if ce~=nil then
		local fgroup=ce:GetTarget()
		mg2=fgroup(ce,e,tp)
		local mf=ce:GetValue()
		sg2=Duel.GetMatchingGroup(s.filter,tp,LOCATION_EXTRA,0,nil,e,tp,mg2,mf,chkf)
	end
    local smg=Duel.GetSynchroMaterial(tp)
	if smg:IsExists(Card.GetHandSynchro,1,nil) then
		local smg2=Duel.GetMatchingGroup(nil,tp,LOCATION_HAND,0,nil)
		if smg2:GetCount()>0 then
        	smg:Merge(smg2)
        end
	end
	local syng=Duel.GetMatchingGroup(s.scfilter,tp,LOCATION_EXTRA,0,nil,tp,smg)
    local b1=#sg1>0 or (sg2~=nil and #sg2>0)
    local b2=syng:GetCount()>0
    if not b1 and not b2 then return end
    local op=aux.SelectFromOptions(tp,
		{b1,aux.Stringid(id,2),1},
		{b2,aux.Stringid(id,3),2})    
	if op==1 then
    	local sg=sg1:Clone()
		if sg2 then sg:Merge(sg2) end
		::cancel::
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
		local tc=sg:Select(tp,1,1,nil):GetFirst()
		if sg1:IsContains(tc) and (sg2==nil or not sg2:IsContains(tc) or ce and not Duel.SelectYesNo(tp,ce:GetDescription())) then
			local mat=Duel.SelectFusionMaterial(tp,tc,mg1,nil,chkf)
			if #mat==0 then goto cancel end
			tc:SetMaterial(mat)
			Duel.SendtoGrave(mat,REASON_EFFECT+REASON_MATERIAL+REASON_FUSION)
			Duel.BreakEffect()
			Duel.SpecialSummon(tc,SUMMON_TYPE_FUSION,tp,tp,false,false,POS_FACEUP)
		elseif ce then
			local mat=Duel.SelectFusionMaterial(tp,tc,mg2,nil,chkf)
			if #mat==0 then goto cancel end
			local fop=ce:GetOperation()
			fop(ce,e,tp,tc,mat)
		end
		tc:CompleteProcedure()
	elseif op==2 then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
		local sync=syng:Select(tp,1,1,nil):GetFirst()		
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SMATERIAL)
		local stg=smg:SelectSubGroup(tp,s.syncheck,false,2,#smg,tp,sync)
		Duel.SynchroSummon(tp,sync,nil,stg,#stg-1,#stg-1)
	end
    aux.FCheckAdditional=nil
end
--同调召唤
function s.SynMixFilter1(c,f1,f2,f3,f4,minc,maxc,syncard,mg,smat,gc,mgchk,goalchk)
	return (not f1 or f1(c,syncard)) and mg:IsExists(s.SynMixFilter2,1,c,f2,f3,f4,minc,maxc,syncard,mg,smat,c,gc,mgchk,goalchk)
end
function s.SynMixFilter2(c,f2,f3,f4,minc,maxc,syncard,mg,smat,c1,gc,mgchk,goalchk)
	if f2 then
		return f2(c,syncard,c1)
			and (mg:IsExists(s.SynMixFilter3,1,Group.FromCards(c1,c),f3,f4,minc,maxc,syncard,mg,smat,c1,c,gc,mgchk,goalchk)
				or minc==0 and s.SynMixFilter4(c,nil,1,1,syncard,mg,smat,c1,nil,nil,gc,mgchk,goalchk))
	else
		return mg:IsExists(s.SynMixFilter4,1,c1,f4,minc,maxc,syncard,mg,smat,c1,nil,nil,gc,mgchk,goalchk)
	end
end
function s.SynMixFilter3(c,f3,f4,minc,maxc,syncard,mg,smat,c1,c2,gc,mgchk,goalchk)
	if f3 then
		return f3(c,syncard,c1,c2)
			and (mg:IsExists(s.SynMixFilter4,1,Group.FromCards(c1,c2,c),f4,minc,maxc,syncard,mg,smat,c1,c2,c,gc,mgchk,goalchk)
				or minc==0 and s.SynMixFilter4(c,nil,1,1,syncard,mg,smat,c1,c2,nil,gc,mgchk,goalchk))
	else
		return mg:IsExists(s.SynMixFilter4,1,Group.FromCards(c1,c2),f4,minc,maxc,syncard,mg,smat,c1,c2,nil,gc,mgchk,goalchk)
	end
end
function s.SynMixFilter4(c,f4,minc,maxc,syncard,mg1,smat,c1,c2,c3,gc,mgchk,goalchk)
	if f4 and not f4(c,syncard,c1,c2,c3) then return false end
	local sg=Group.FromCards(c1,c)
	if c2 then sg:AddCard(c2) end
	if c3 then sg:AddCard(c3) end
	local mg=mg1:Clone()
	if f4 then
		mg=mg:Filter(f4,sg,syncard,c1,c2,c3)
	else
		mg:Sub(sg)
	end
	return s.SynMixCheck(mg,sg,minc-1,maxc-1,syncard,mg1,smat,gc,mgchk,goalchk)
end
function s.SynMixCheck(mg,sg1,minc,maxc,syncard,mg1,smat,gc,mgchk,goalchk)
	local tp=syncard:GetControler()
	local sg=Group.CreateGroup()
	if minc<=0 and s.SynMixCheckGoal(tp,sg1,0,0,syncard,sg,smat,gc,mgchk,goalchk) then return true end
	if maxc==0 then return false end
	local fulltraversal=#mg<=5 or mg1:IsExists(Card.IsHasEffect,1,nil,89818984)
	return mg:IsExists(s.SynMixCheckRecursive,1,nil,tp,sg,mg,0,minc,maxc,syncard,sg1,smat,gc,mgchk,goalchk,fulltraversal)
end
function s.SynMixCheckRecursive(c,tp,sg,mg,ct,minc,maxc,syncard,sg1,smat,gc,mgchk,goalchk,fulltraversal)
	sg:AddCard(c)
	ct=ct+1
	local res=s.SynMixCheckGoal(tp,sg,minc,ct,syncard,sg1,smat,gc,mgchk,goalchk)
	if not res and ct<maxc
		and (fulltraversal or not Auxiliary.SynMixCheckPrune(sg,sg1,syncard)) then
		res=mg:IsExists(s.SynMixCheckRecursive,1,sg,tp,sg,mg,ct,minc,maxc,syncard,sg1,smat,gc,mgchk,goalchk,fulltraversal)
	end
	sg:RemoveCard(c)
	ct=ct-1
	return res
end
function s.SynMixCheckGoal(tp,sg,minc,ct,syncard,sg1,smat,gc,mgchk,goalchk)
	if goalchk then return true end
	if ct<minc then return false end
	local g=sg+sg1
	if Duel.GetLocationCountFromEx(tp,tp,g,syncard)<=0 then return false end
	if gc and not gc(g,syncard,tp) then return false end
	if smat and not g:IsContains(smat) then return false end
	if not Auxiliary.MustMaterialCheck(g,tp,EFFECT_MUST_BE_SMATERIAL) then return false end
	if Duel.IsPlayerAffectedByEffect(tp,8173184)
		and not g:IsExists(Auxiliary.Tuner(Card.IsSetCard,0x2),1,nil,syncard) then return false end
	if not (g:CheckWithSumEqual(Card.GetSynchroLevel,syncard:GetLevel(),g:GetCount(),g:GetCount(),syncard)
    	or g:CheckWithSumEqual(Card.GetSynchroLevel,6,g:GetCount(),g:GetCount(),syncard))
		and (not g:IsExists(Card.IsHasEffect,1,nil,89818984)
		or not g:CheckWithSumEqual(Auxiliary.GetSynchroLevelFlowerCardian,syncard:GetLevel(),g:GetCount(),g:GetCount(),syncard))
		then return false end
	if not (mgchk or Auxiliary.SynMixHandCheck(g,tp,syncard)) then return false end
	for c in Auxiliary.Next(g) do
		local le,lf,lloc,lmin,lmax=c:GetTunerLimit()
		if le then
			local lct=g:GetCount()-1
			if lloc then
				local llct=g:FilterCount(Card.IsLocation,c,lloc)
				if llct~=lct then return false end
			end
			if lf and g:IsExists(Auxiliary.SynLimitFilter,1,c,lf,le,syncard) then return false end
			if (lmin and lct<lmin) or (lmax and lct>lmax) then return false end
		end
	end
	return true
end
function s.SynMixCondition(f1,f2,f3,f4,minct,maxct,gc)
	return	function(e,c,smat,mg1,min,max)
				if c==nil then return true end
				if c:IsType(TYPE_PENDULUM) and c:IsFaceup() then return false end
				local minc=minct
				local maxc=maxct
				if min then
					local exct=0
					if f2 then exct=exct+1 end
					if f3 then exct=exct+1 end
					if min-exct>minc then minc=min-exct end
					if max-exct<maxc then maxc=max-exct end
					if minc>maxc then return false end
				end
				local tp=c:GetControler()
				if Duel.IsPlayerAffectedByEffect(tp,8173184) then
					Duel.RegisterFlagEffect(tp,8173184+1,0,0,1)
				end
				if smat and not smat:IsCanBeSynchroMaterial(c) then
					Duel.ResetFlagEffect(tp,8173184+1)
					return false
				end
				local mg
				local mgchk=false
				local goalchk=false
				if mg1 then
					mg=mg1:Filter(Card.IsCanBeSynchroMaterial,nil,c)
					mgchk=true
					if min and min==max and #mg==#mg1 and #mg==min+1 then
						goalchk=s.SynMixCheckGoal(tp,mg,0,0,c,Group.CreateGroup(),smat,gc,mgchk,goalchk)
						if not goalchk then
							Duel.ResetFlagEffect(tp,8173184+1)
							return false
						end
					end
				else
					mg=Auxiliary.GetSynMaterials(tp,c)
				end
				if smat~=nil then mg:AddCard(smat) end
				local res=mg:IsExists(s.SynMixFilter1,1,nil,f1,f2,f3,f4,minc,maxc,c,mg,smat,gc,mgchk,goalchk)
				Duel.ResetFlagEffect(tp,8173184+1)
				return res
			end
end
function s.SynMixTarget(f1,f2,f3,f4,minct,maxct,gc)
	return	function(e,tp,eg,ep,ev,re,r,rp,chk,c,smat,mg1,min,max)
				local minc=minct
				local maxc=maxct
				if min then
					local exct=0
					if f2 then exct=exct+1 end
					if f3 then exct=exct+1 end
					if min-exct>minc then minc=min-exct end
					if max-exct<maxc then maxc=max-exct end
					if minc>maxc then return false end
				end
				::SynMixTargetSelectStart::
				if Duel.IsPlayerAffectedByEffect(tp,8173184) then
					Duel.RegisterFlagEffect(tp,8173184+1,0,0,1)
				end
				local cancel=Duel.IsSummonCancelable()
				local g=Group.CreateGroup()
				local mg
				local mgchk=false
				local goalchk=false
				if mg1 then
					mg=mg1:Filter(Card.IsCanBeSynchroMaterial,nil,c)
					mgchk=true
					if min and min==max and #mg==#mg1 and #mg==min+1 and not cancel then
						g:Merge(mg)
						g:KeepAlive()
						e:SetLabelObject(g)
						Duel.ResetFlagEffect(tp,8173184+1)
						return true
					end
				else
					mg=Auxiliary.GetSynMaterials(tp,c)
				end
				if smat~=nil then mg:AddCard(smat) end
				local c1
				local c2
				local c3
				local g4=Group.CreateGroup()
				Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SMATERIAL)
				c1=mg:Filter(s.SynMixFilter1,nil,f1,f2,f3,f4,minc,maxc,c,mg,smat,gc,mgchk,goalchk):SelectUnselect(g,tp,false,cancel,1,1)
				if not c1 then goto SynMixTargetSelectCancel end
				g:AddCard(c1)
				if f2 then
					Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SMATERIAL)
					c2=mg:Filter(s.SynMixFilter2,g,f2,f3,f4,minc,maxc,c,mg,smat,c1,gc,mgchk,goalchk):SelectUnselect(g,tp,false,cancel,1,1)
					if not c2 then goto SynMixTargetSelectCancel end
					if g:IsContains(c2) then goto SynMixTargetSelectStart end
					g:AddCard(c2)
					if f3 then
						Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SMATERIAL)
						c3=mg:Filter(s.SynMixFilter3,g,f3,f4,minc,maxc,c,mg,smat,c1,c2,gc,mgchk,goalchk):SelectUnselect(g,tp,false,cancel,1,1)
						if not c3 then goto SynMixTargetSelectCancel end
						if g:IsContains(c3) then goto SynMixTargetSelectStart end
						g:AddCard(c3)
					end
				end
				for i=0,maxc-1 do
					local mg2=mg:Clone()
					if f4 then
						mg2=mg2:Filter(f4,g,c,c1,c2,c3)
					else
						mg2:Sub(g)
					end
					local fulltraversal=mg:IsExists(Card.IsHasEffect,1,nil,89818984)
					local cg=mg2:Filter(s.SynMixCheckRecursive,g4,tp,g4,mg2,i,minc,maxc,c,g,smat,gc,mgchk,goalchk,fulltraversal)
					if cg:GetCount()==0 then break end
					local finish=s.SynMixCheckGoal(tp,g4,minc,i,c,g,smat,gc,mgchk,goalchk)
					Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SMATERIAL)
					local c4=cg:SelectUnselect(g+g4,tp,finish,cancel,minc,maxc)
					if not c4 then
						if finish then break
						else goto SynMixTargetSelectCancel end
					end
					if g:IsContains(c4) or g4:IsContains(c4) then goto SynMixTargetSelectStart end
					g4:AddCard(c4)
				end
				g:Merge(g4)
				if g:GetCount()>0 then
					g:KeepAlive()
					e:SetLabelObject(g)
					Duel.ResetFlagEffect(tp,8173184+1)
					return true
				end
				::SynMixTargetSelectCancel::
				Duel.ResetFlagEffect(tp,8173184+1)
				return false
			end
end