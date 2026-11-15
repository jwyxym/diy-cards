local s,id=GetID()
local id_dream_inf = 58850000

function s.initial_effect(c)
    c:EnableReviveLimit()

    local e1=Effect.CreateEffect(c)
    e1:SetType(EFFECT_TYPE_FIELD)
    e1:SetCode(EFFECT_SPSUMMON_PROC)
    e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
    e1:SetRange(LOCATION_EXTRA)
    e1:SetCondition(s.SynMixCondition(aux.Tuner(Card.IsRace,RACE_PSYCHO),nil,nil,aux.NonTuner(nil),1,99,nil))
    e1:SetTarget(s.SynMixTarget(aux.Tuner(Card.IsRace,RACE_PSYCHO),nil,nil,aux.NonTuner(nil),1,99,nil))
    e1:SetOperation(s.SynMixOperation(aux.Tuner(Card.IsRace,RACE_PSYCHO),nil,nil,aux.NonTuner(nil),1,99,nil))
    e1:SetValue(SUMMON_TYPE_SYNCHRO)
    c:RegisterEffect(e1)

    local e2=Effect.CreateEffect(c)
    e2:SetDescription(aux.Stringid(id,1))
    e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
    e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
    e2:SetCode(EVENT_DESTROYED)
    e2:SetProperty(EFFECT_FLAG_DELAY)
    e2:SetRange(LOCATION_MZONE)
    e2:SetCountLimit(1,id+1)
    e2:SetCondition(s.gycon)
    e2:SetTarget(s.gytg)
    e2:SetOperation(s.gyop)
    c:RegisterEffect(e2)

    local e3=Effect.CreateEffect(c)
    e3:SetDescription(aux.Stringid(id,2))
    e3:SetCategory(CATEGORY_SPECIAL_SUMMON)
    e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
    e3:SetCode(EVENT_CHAINING)
    e3:SetProperty(EFFECT_FLAG_DELAY)
    e3:SetRange(LOCATION_MZONE)
    e3:SetCountLimit(1,id+2)
    e3:SetCondition(s.chcon)
    e3:SetTarget(s.chtg)
    e3:SetOperation(s.chop)
    c:RegisterEffect(e3)
end

function s.SynMaterialFilterExtra(c,tp,syncard)
    return c:IsCanBeSynchroMaterial(syncard) and c:GetOwner()==tp
end

function s.GetSynMaterials(tp,syncard)
    local mg=Duel.GetSynchroMaterial(tp):Filter(aux.SynMaterialFilter,nil,syncard)
    if mg:IsExists(Card.GetHandSynchro,1,nil) then
        local mg2=Duel.GetMatchingGroup(Card.IsCanBeSynchroMaterial,tp,LOCATION_HAND,0,nil,syncard)
        if mg2:GetCount()>0 then mg:Merge(mg2) end
    end
    local mg3=Duel.GetMatchingGroup(s.SynMaterialFilterExtra,tp,0,LOCATION_MZONE,nil,tp,syncard)
    if mg3:GetCount()>0 and Duel.GetFlagEffect(tp,id)==0 then mg:Merge(mg3) end
    return mg
end

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
        and (fulltraversal or not aux.SynMixCheckPrune(sg,sg1,syncard)) then
        res=mg:IsExists(s.SynMixCheckRecursive,1,sg,tp,sg,mg,ct,minc,maxc,syncard,sg1,smat,gc,mgchk,goalchk,fulltraversal)
    end
    sg:RemoveCard(c)
    ct=ct-1
    return res
end
function s.MekhaneFilter(c,tp)
    return c:IsControler(1-tp) and c:GetOwner()~=tp
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
        and g:FilterCount(Card.IsControler,nil,1-tp)<=1 and not g:IsExists(s.MekhaneFilter,1,nil,tp)) and (not g:IsExists(Card.IsHasEffect,1,nil,89818984)
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
    return function(e,c,smat,mg1,min,max)
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
            mg=s.GetSynMaterials(tp,c)
        end
        if smat~=nil then mg:AddCard(smat) end
        local res=mg:IsExists(s.SynMixFilter1,1,nil,f1,f2,f3,f4,minc,maxc,c,mg,smat,gc,mgchk,goalchk)
        Duel.ResetFlagEffect(tp,8173184+1)
        return res
    end
end
function s.SynMixTarget(f1,f2,f3,f4,minct,maxct,gc)
    return function(e,tp,eg,ep,ev,re,r,rp,chk,c,smat,mg1,min,max)
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
            mg=s.GetSynMaterials(tp,c)
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
function s.SynMixOperation(f1,f2,f3,f4,minct,maxct,gc)
    return function(e,tp,eg,ep,ev,re,r,rp,c,smat,mg,min,max)
        local g=e:GetLabelObject()
        c:SetMaterial(g)
        if g:IsExists(Card.IsControler,1,nil,1-tp) then
            Duel.RegisterFlagEffect(tp,id,RESET_PHASE+PHASE_END,0,1)
        end
        Duel.SendtoGrave(g,REASON_MATERIAL+REASON_SYNCHRO)
        g:DeleteGroup()
    end
end

function s.gycon(e,tp,eg,ep,ev,re,r,rp)
    return eg:IsExists(function(c) 
        return c:IsCode(id_dream_inf) and c:IsPreviousLocation(LOCATION_FZONE) 
    end, 1, nil)
end

function s.spfilter(c,e,tp)
    return aux.IsCodeListed(c, id_dream_inf) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end

function s.gytg(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0 and Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_GRAVE,0,1,nil,e,tp) end
    Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_GRAVE)
end

function s.gyop(e,tp,eg,ep,ev,re,r,rp)
    if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
    local g=Duel.SelectMatchingCard(tp,s.spfilter,tp,LOCATION_GRAVE,0,1,1,nil,e,tp)
    if #g>0 then
        Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
    end
end

function s.chcon(e,tp,eg,ep,ev,re,r,rp)
    if not re then return false end
    local rc=re:GetHandler()
    return (aux.IsCodeListed(rc, id_dream_inf) or rc:IsCode(58850010) or rc:IsCode(58850030) or rc:IsCode(58850110)) 
        and rc:GetControler()==tp 
        and not rc:IsAttribute(ATTRIBUTE_FIRE) 
end

function s.chtg(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return Duel.IsExistingMatchingCard(Card.IsSynchroSummonable,tp,LOCATION_EXTRA,0,1,nil,nil) end
    Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_EXTRA)
end

function s.splimit(e,c)
    return not c:IsRace(RACE_PSYCHO)
end

function s.chop(e,tp,eg,ep,ev,re,r,rp)
    local g=Duel.GetMatchingGroup(Card.IsSynchroSummonable,tp,LOCATION_EXTRA,0,nil,nil)
    if g:GetCount()>0 then
        Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
        local sg=g:Select(tp,1,1,nil)
        Duel.SynchroSummon(tp,sg:GetFirst(),nil)
    end

    local e3=Effect.CreateEffect(e:GetHandler())
    e3:SetDescription(aux.Stringid(id,7))
    e3:SetType(EFFECT_TYPE_FIELD)
    e3:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
    e3:SetProperty(EFFECT_FLAG_PLAYER_TARGET+EFFECT_FLAG_CLIENT_HINT)
    e3:SetTargetRange(1,0)
    e3:SetTarget(s.splimit)
    e3:SetReset(RESET_PHASE+PHASE_END)
    Duel.RegisterEffect(e3,tp)
end